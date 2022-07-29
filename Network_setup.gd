extends Control

var player = load("res://Player1.tscn")
var n_players = 1

#var current_spawn_location_instance_number = 1
#var current_player_for_spawn_location_number = null

onready var multiplayer_config_ui = $Multiplayer_configure
onready var server_ip_address = $Multiplayer_configure/Server_ip_address

#onready var username_text_edit = $Multiplayer_configure/Username_text_edit

onready var device_ip_address = $Multiplayer_configure/Device_ip_address
#onready var start_game = $UI/Start_game

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	device_ip_address.text = Network.ip_address
#	server_ip_address = "127.0.0.1" # LUCAS: juste pour moi, pour m'économiser de la retaper à chaque fois

func _player_connected(id) -> void:
	# remote func network_peer_connected : this is called whenever another peer connects
	print("Player " + str(id) + " has connected")
	
	rpc_id(id, "welcome_new_client", n_players)
	
remote func welcome_new_client(their_n_players) -> void:
	var their_id = get_tree().get_rpc_sender_id()
	instance_players(their_id, their_n_players)

func _player_disconnected(id) -> void:
	# remote func network_peer_disconnected : this is called whenever another peer disconnects
	print("Player " + str(id) + " has disconnected")
	
	if Players.has_node(str(id)):
#		Persistent_nodes.get_node(str(id)).username_text_instance.queue_free()
		Players.get_node(str(id)).queue_free()

func _on_Create_server_pressed():
#	if username_text_edit.text != "":
#		Network.current_player_username = username_text_edit.text
	multiplayer_config_ui.hide()
	Network.create_server()
	
	instance_players(get_tree().get_network_unique_id(), n_players)

func _on_Join_server_pressed():
	print("_on_Join_server_pressed")
	var ip_address
	if server_ip_address.text != "":
		ip_address = server_ip_address.text
	else:
		ip_address = "127.0.0.1"
	print(ip_address)
	multiplayer_config_ui.hide()
#	username_text_edit.hide()

	Network.ip_address = ip_address
	Network.join_server()
#	Global.instance_node(load("res://Server_browser.tscn"), self)

func _connected_to_server() -> void:
	# vanilla func : this is called whenever we, a client, connect to the server
	print("Successfully connected to the server")
	yield(get_tree().create_timer(0.1), "timeout") # what was this useful for ?
	instance_players(get_tree().get_network_unique_id(), n_players)

func instance_players(id, n_players) -> void:
	for player_idx in range(n_players):
		var player_instance = Global.instance_node_at_location(player, Players, Vector2(rand_range(0, 1920), rand_range(0, 1080)))
		player_instance.set_network_master(id)
		player_instance.player_idx = player_idx
		player_instance.name = str(id) # in _player_disconnected we assume that name == master_network_id

#func _connected_to_server() -> void:
#	yield(get_tree().create_timer(0.1), "timeout")
#	instance_player(get_tree().get_network_unique_id())
#
#func instance_player(id) -> void:
#	var player_instance = Global.instance_node_at_location(player, Persistent_nodes, get_node("Spawn_locations/" + str(current_spawn_location_instance_number)).global_position)
#	player_instance.name = str(id)
#	player_instance.set_network_master(id)
#	player_instance.username = username_text_edit.text
#	current_spawn_location_instance_number += 1
#
#func _on_Start_game_pressed():
#	rpc("switch_to_game")
#
#sync func switch_to_game() -> void:
#	for child in Persistent_nodes.get_children():
#		if child.is_in_group("Player"):
#			child.update_shoot_mode(true)
#
#	get_tree().change_scene("res://Game.tscn")


