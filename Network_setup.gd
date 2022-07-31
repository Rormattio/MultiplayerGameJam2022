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

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	if not Global.DEBUG:
		create_server_and_client.queue_free()

	connection_status.hide()

	Upnp.connect("upnp_completed", self, "_upnp_completed")
	external_ip_address_label.hide()
	device_external_ip_address.hide()

	device_local_ip_address.text = Network.ip_address

func _upnp_completed(error):
	print("upnp done ", Upnp.external_ip_address)
	if error == UPNP.UPNP_RESULT_SUCCESS:
		device_external_ip_address.text = Upnp.external_ip_address
		device_external_ip_address.show()
		external_ip_address_label.show()

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")

	if is_network_master():
		connection_status.text = "Connected to chef"
	else:
		connection_status.text = "Connected to waiter"
	connection_status.add_color_override("font_color", "#00ff00")
	connection_status.show()

	if is_network_master():
		start()

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")

	if is_network_master():
		connection_status.text = "Disconnected from chef"
	else:
		connection_status.text = "Disconnected from waiter"
	connection_status.add_color_override("font_color", "#ff0000")
	connection_status.show()

func _on_Create_server_pressed():
	AudioSfx.play(Global.Sfx.CLICK)
	multiplayer_config_ui.hide()
	Network.create_server()

	instanciate_object_at_root(dining_room_level_scene, get_tree().get_network_unique_id())

func _on_Join_server_pressed():
	AudioSfx.play(Global.Sfx.CLICK)
	print("_on_Join_server_pressed")
	var ip_address
	if server_ip_address.text != "":
		ip_address = server_ip_address.text
	else:
		ip_address = "127.0.0.1"
	print(ip_address)
	multiplayer_config_ui.hide()

	Network.ip_address = ip_address
	Network.join_server()

func _on_Create_server_and_client_pressed():
	AudioSfx.play(Global.Sfx.CLICK)
	multiplayer_config_ui.hide()
	Network.create_server()

	var dual_scene_handle = dual_scene.instance()
	get_node("/root/Main").add_child(dual_scene_handle)

	var left_pane_handle = get_node("/root/Main/DualScene/LeftPane")
	var right_pane_handle = get_node("/root/Main/DualScene/RightPane")

	var _dining_room_level_scene_handle = instanciate_object(dining_room_level_scene, get_tree().get_network_unique_id(), left_pane_handle)
	var _kitchen_scene_handle = instanciate_object(kitchen_scene, get_tree().get_network_unique_id(), right_pane_handle)

func _connected_to_server() -> void:
	instanciate_object_at_root(kitchen_scene, get_tree().get_network_unique_id())

	start()

func instanciate_object_at_root(scene, id):
	var root = get_node("/root/Main")
	return instanciate_object(scene, id, root)

func instanciate_object(scene, id, root):
	var p = scene.instance()
	p.name = str(id)
	p.set_network_master(id)
	root.add_child(p)
	return p

func start():
	print("start game")
