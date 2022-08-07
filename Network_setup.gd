extends Node

var kitchen_scene = preload("res://scenes/kitchen/Kitchen.tscn")
var dining_room_level_scene = preload("res://scenes/dining_room/Dining_room_level.tscn")
var dual_scene = preload("res://scenes/dual_scene.tscn")

onready var multiplayer_config_ui = $Multiplayer_configure
onready var server_ip_address = $Multiplayer_configure/Server_ip_address

onready var device_local_ip_address = $Multiplayer_configure/Device_local_ip_address
onready var external_ip_address_label = $Multiplayer_configure/external_ip_address_label
onready var device_external_ip_address = $Multiplayer_configure/Device_external_ip_address
onready var create_server_and_client = $Multiplayer_configure/create_server_and_client
onready var connection_status = $connection_status

onready var lobby = $Lobby

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")

	Global.connect("lobby_role_sent", self, "_on_LobbyRole_sent")
	Global.connect("lobby_start_game_sent", self, "_on_LobbyStartGame_sent")
	Global.connect("player_quit_sent", self, "_player_disconnected")

	if not Global.DEBUG:
		create_server_and_client.queue_free()

	lobby.hide()
	$Lobby/ChooseCheffe.connect("pressed", self, "_on_ChooseCheffe_pressed")
	$Lobby/ChooseWaiter.connect("pressed", self, "_on_ChooseWaiter_pressed")
	$Lobby/StartGame.connect("pressed", self, "_on_StartGame_pressed")
	$Lobby/Cancel.connect("pressed", self, "_on_LobbyCancel_pressed")
	$Lobby/GameStartTimer.connect("timeout", self, "_on_GameStartTimer_timeout")

	$Lobby/GameTimer.connect("timeout", self, "_on_GameTimer_timeout")
	$ResultsScreen/NewRound.connect("pressed", self, "_on_NewRound_pressed")

	$ResultsScreen.hide()
	$GameTimerUI.hide()

	$DisconnectedPopup.hide()
	$DisconnectedPopup/RestartButton.connect("pressed", self, "_on_Restart_pressed")

	$Multiplayer_configure/QuitToDesktop.connect("pressed", self, "_on_ExitToDesktop_pressed")

	Upnp.connect("upnp_completed", self, "_upnp_completed")
	external_ip_address_label.hide()
	device_external_ip_address.hide()

	device_local_ip_address.text = Network.ip_address

	enter_title_screen()

func _upnp_completed(error):
	Global.logger("upnp done " + Upnp.external_ip_address)
	if error == UPNP.UPNP_RESULT_SUCCESS:
		device_external_ip_address.text = Upnp.external_ip_address
		device_external_ip_address.show()
		external_ip_address_label.show()

func _on_Create_server_pressed():
	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)
	Network.create_server()

	enter_lobby_from_title_screen()

func _on_Join_server_pressed():
	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)
	Global.logger("_on_Join_server_pressed")
	var ip_address
	if server_ip_address.text != "":
		ip_address = server_ip_address.text
	else:
		ip_address = "127.0.0.1"
	Global.logger(ip_address)

	Network.ip_address = ip_address
	Network.join_server()

	enter_lobby_from_title_screen()

func _on_Create_server_and_client_pressed():
	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)
	multiplayer_config_ui.hide()
	Network.create_server()

	var dual_scene_handle = dual_scene.instance()
	get_node("/root/Main").add_child(dual_scene_handle)

	var left_pane_handle = get_node("/root/Main/DualScene/LeftPane")
	var right_pane_handle = get_node("/root/Main/DualScene/RightPane")

	var _dining_room_level_scene_handle = instanciate_object(dining_room_level_scene, get_tree().get_network_unique_id(), left_pane_handle)
	var _kitchen_scene_handle = instanciate_object(kitchen_scene, get_tree().get_network_unique_id(), right_pane_handle)

func _connected_to_server() -> void:
	#start()
	pass

func instanciate_object_at_root(scene, id):
	var root = get_node("/root/Main")
	return instanciate_object(scene, id, root)

func instanciate_object(scene, id, root):
	var p = scene.instance()
	p.name = str(id)
	p.set_network_master(id)
	root.add_child(p)
	return p

enum PlayerRole {
	CHEFFE,
	WAITER,
}

enum LobbyState {
	TITLE_SCREEN,
	WAITING_FOR_PLAYER,
	CHOOSING_ROLES,
	CAN_START_GAME,
	START_GAME_COUNTDOWN,
	GAME_STARTED,
	RESULT_SCREEN,
}

var chosen_role
var other_role
var start_countdown
var lobby_state
var fade_alpha

const GAME_ROUND_TIME_SECONDS = 3 * 60

func enter_lobby_from_title_screen():
	multiplayer_config_ui.hide()

	lobby_state = LobbyState.WAITING_FOR_PLAYER

	$Lobby/ChooseCheffe.disabled = true
	$Lobby/ChooseWaiter.disabled = true
	$Lobby/StartGame.disabled = true
	$Lobby/Cancel.disabled = false
	$Lobby/FadeToBlack.hide()
	$Lobby/CountdownLabel.hide()

	$Lobby/MyRole.hide()
	$Lobby/TheirRole.hide()

	chosen_role = null
	other_role = null

	lobby.show()

	connection_status.text = "Waiting for other player..."
	connection_status.add_color_override("font_color", "#ffff00")
	connection_status.show()

func enter_lobby_from_result_screen():
	multiplayer_config_ui.hide()

	lobby_state = LobbyState.CHOOSING_ROLES

	$Lobby/ChooseCheffe.disabled = false
	$Lobby/ChooseWaiter.disabled = false
	$Lobby/StartGame.disabled = true
	$Lobby/Cancel.disabled = false
	$Lobby/FadeToBlack.hide()
	$Lobby/CountdownLabel.hide()

	$Lobby/MyRole.hide()
	$Lobby/TheirRole.hide()

	chosen_role = null
	other_role = null

	$Lobby/CheffeDescBgBorder.color = ROLE_UNASSIGNED_COLOR
	$Lobby/WaiterDescBgBorder.color = ROLE_UNASSIGNED_COLOR

	lobby.show()

func exit_lobby():
	Global.player_send_quit(Network.get_id())
	Network.stop()

	lobby_state = LobbyState.TITLE_SCREEN
	lobby.hide()

	enter_title_screen()

func _exit_tree():
	if get_tree().network_peer != null:
		Global.player_send_quit(Network.get_id())
	Network.stop()

func _player_connected(id) -> void:
	Global.logger("Player " + str(id) + " has connected")

	connection_status.text = "Connected to other player"
	connection_status.add_color_override("font_color", "#00ff00")
	connection_status.show()

	$Lobby/ChooseCheffe.disabled = false
	$Lobby/ChooseWaiter.disabled = false
	lobby_state = LobbyState.CHOOSING_ROLES

	Network.stop_listening_for_peers()

func _player_disconnected(id) -> void:
	Global.logger("Player " + str(id) + " has disconnected")

	connection_status.text = "Disconnected"
	connection_status.add_color_override("font_color", "#ff0000")
	connection_status.show()

	$DisconnectedPopup.show()

func _on_ChooseCheffe_pressed():
	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)
	chosen_role = PlayerRole.CHEFFE
	Global.lobby_send_role(chosen_role)

	$Lobby/MyRole.rect_position.x = 312
	$Lobby/MyRole.show()

	update_role_feedback()

func _on_ChooseWaiter_pressed():
	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)
	chosen_role = PlayerRole.WAITER
	Global.lobby_send_role(chosen_role)

	$Lobby/MyRole.rect_position.x = 864
	$Lobby/MyRole.show()

	update_role_feedback()

func _on_LobbyRole_sent(role):
	other_role = role

	match role:
		PlayerRole.CHEFFE:
			$Lobby/TheirRole.rect_position.x = 312
		PlayerRole.WAITER:
			$Lobby/TheirRole.rect_position.x = 864
		_: assert(false)

	$Lobby/TheirRole.show()

	update_role_feedback()

func _on_LobbyCancel_pressed():
	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)
	exit_lobby()

const ROLE_MISMATCH_COLOR = Color("#ff0000")
const ROLE_OK_COLOR = Color("#00ff00")
const ROLE_UNASSIGNED_COLOR = Color("#393935")

func update_role_feedback():
	match [chosen_role, other_role]:
		[PlayerRole.CHEFFE, PlayerRole.CHEFFE]:
			$Lobby/CheffeDescBgBorder.color = ROLE_MISMATCH_COLOR
			$Lobby/MyRole.add_color_override("font_color", ROLE_MISMATCH_COLOR)
			$Lobby/TheirRole.add_color_override("font_color", ROLE_MISMATCH_COLOR)
			$Lobby/WaiterDescBgBorder.color = ROLE_UNASSIGNED_COLOR

		[PlayerRole.WAITER, PlayerRole.WAITER]:
			$Lobby/WaiterDescBgBorder.color = ROLE_MISMATCH_COLOR
			$Lobby/MyRole.add_color_override("font_color", ROLE_MISMATCH_COLOR)
			$Lobby/TheirRole.add_color_override("font_color", ROLE_MISMATCH_COLOR)
			$Lobby/CheffeDescBgBorder.color = ROLE_UNASSIGNED_COLOR

		[PlayerRole.CHEFFE, PlayerRole.WAITER]:
			$Lobby/CheffeDescBgBorder.color = ROLE_OK_COLOR
			$Lobby/MyRole.add_color_override("font_color", ROLE_OK_COLOR)
			$Lobby/TheirRole.add_color_override("font_color", ROLE_OK_COLOR)
			$Lobby/WaiterDescBgBorder.color = ROLE_OK_COLOR

		[PlayerRole.WAITER, PlayerRole.CHEFFE]:
			$Lobby/CheffeDescBgBorder.color = ROLE_OK_COLOR
			$Lobby/MyRole.add_color_override("font_color", ROLE_OK_COLOR)
			$Lobby/TheirRole.add_color_override("font_color", ROLE_OK_COLOR)
			$Lobby/WaiterDescBgBorder.color = ROLE_OK_COLOR

		[PlayerRole.CHEFFE, null]:
			$Lobby/CheffeDescBgBorder.color = ROLE_OK_COLOR
			$Lobby/MyRole.add_color_override("font_color", ROLE_OK_COLOR)
			$Lobby/WaiterDescBgBorder.color = ROLE_UNASSIGNED_COLOR

		[PlayerRole.WAITER, null]:
			$Lobby/WaiterDescBgBorder.color = ROLE_OK_COLOR
			$Lobby/MyRole.add_color_override("font_color", ROLE_OK_COLOR)
			$Lobby/CheffeDescBgBorder.color = ROLE_UNASSIGNED_COLOR

		[null, PlayerRole.CHEFFE]:
			$Lobby/CheffeDescBgBorder.color = ROLE_OK_COLOR
			$Lobby/TheirRole.add_color_override("font_color", ROLE_OK_COLOR)
			$Lobby/WaiterDescBgBorder.color = ROLE_UNASSIGNED_COLOR

		[null, PlayerRole.WAITER]:
			$Lobby/WaiterDescBgBorder.color = ROLE_OK_COLOR
			$Lobby/TheirRole.add_color_override("font_color", ROLE_OK_COLOR)
			$Lobby/CheffeDescBgBorder.color = ROLE_UNASSIGNED_COLOR

		[null, null]: assert(false)

	check_if_game_can_start()

func check_if_game_can_start():
	var can_start = (chosen_role != null and other_role != null and chosen_role != other_role)

	lobby_state = LobbyState.CAN_START_GAME if can_start else LobbyState.CHOOSING_ROLES
	$Lobby/StartGame.disabled = !can_start

func _on_StartGame_pressed():
	assert(chosen_role != null)

	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)

	Global.lobby_send_start_game()
	_on_LobbyStartGame_sent()

func _on_GameStartTimer_timeout():
	start_countdown -= 1
	if start_countdown > 0:
		$Lobby/CountdownLabel.text += str(start_countdown) + ".."
		$Lobby/GameStartTimer.start()
	else:
		start_game()

func update_fade_color(alpha):
	$Lobby/FadeToBlack.color = Color(0.12, 0.11, 0.10, alpha)

func _physics_process(_delta):
	if lobby_state == LobbyState.START_GAME_COUNTDOWN:
		fade_alpha += 1.0 / (3 * 60.0)
		if fade_alpha >= 1.0:
			fade_alpha = 1.0
		update_fade_color(fade_alpha)

	if lobby_state == LobbyState.GAME_STARTED:
		var t = $Lobby/GameTimer.time_left
		var minutes = int(floor(t / 60.0))
		var seconds = int(t - minutes * 60.0)
		$GameTimerUI/Label.text = "%d:%02d" % [minutes, seconds]
		if t <= 10.0:
			$GameTimerUI/Bg.modulate = Color("#ff0000")

func _on_LobbyStartGame_sent():
	if lobby_state == LobbyState.START_GAME_COUNTDOWN:
		return
	assert(lobby_state == LobbyState.CAN_START_GAME)

	lobby_state = LobbyState.START_GAME_COUNTDOWN
	start_countdown = 3

	$Lobby/ChooseCheffe.disabled = true
	$Lobby/ChooseWaiter.disabled = true
	$Lobby/StartGame.disabled = true
	$Lobby/Cancel.disabled = true

	$Lobby/CountdownLabel.text = "Game starting in 3.."
	$Lobby/CountdownLabel.show()

	fade_alpha = 0.0
	update_fade_color(fade_alpha)
	$Lobby/FadeToBlack.show()

	$Lobby/GameStartTimer.start()

var player_ready_count

func start_game():
	assert(lobby_state == LobbyState.START_GAME_COUNTDOWN)

	Global.logger("start game")

	if chosen_role == PlayerRole.CHEFFE:
		instanciate_object(kitchen_scene, Network.get_id(), $RoleScene)
	else:
		instanciate_object(dining_room_level_scene, Network.get_id(), $RoleScene)

	lobby.hide()

	lobby_state = LobbyState.GAME_STARTED

	# Need to wait to sync players because instanciate above takes different time
	player_ready_count = 0
	rpc("player_ready")

remotesync func player_ready():
	player_ready_count += 1
	if player_ready_count == 2:
		if is_network_master():
			rpc("start_game_timer")

remotesync func start_game_timer():
	$Lobby/GameTimer.wait_time = GAME_ROUND_TIME_SECONDS
	$Lobby/GameTimer.start()
	$GameTimerUI.show()

func enter_title_screen():
	lobby_state = LobbyState.TITLE_SCREEN
	lobby.hide()

	connection_status.hide()
	$GameTimerUI.hide()
	multiplayer_config_ui.show()

func _on_Restart_pressed():
	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)
	for n in $RoleScene.get_children():
		n.queue_free()

	Network.stop()
	$DisconnectedPopup.hide()

	enter_title_screen()

func _on_ExitToDesktop_pressed():
	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)
	get_tree().quit()

func _unhandled_input(event: InputEvent):
	if Input.is_action_pressed("ui_toggle_fullscreen"):
		OS.set_window_fullscreen(!OS.window_fullscreen)

func _on_GameTimer_timeout():
	if is_network_master():
		rpc("enter_result_screen")

remotesync func enter_result_screen():
	lobby_state = LobbyState.RESULT_SCREEN

	var final_score

	for n in $RoleScene.get_children():
		final_score = n.total_score
		n.queue_free()

	$GameTimerUI.hide()

	$ResultsScreen/FinalScore.hide()
	$ResultsScreen.show()

	yield(get_tree().create_timer(1), "timeout")

	$ResultsScreen/FinalScore/Score.text = str(final_score) + "$"
	$ResultsScreen/FinalScore.show()


func _on_NewRound_pressed():
	rpc("do_enter_lobby_from_result_screen")

remotesync func do_enter_lobby_from_result_screen():
	if lobby_state != LobbyState.RESULT_SCREEN:
		return

	$ResultsScreen.hide()
	enter_lobby_from_result_screen()
