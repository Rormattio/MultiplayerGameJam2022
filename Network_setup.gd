extends Node

var kitchen_scene = preload("res://scenes/kitchen/Kitchen.tscn")
var dining_room_scene = preload("res://scenes/dining_room/Dining_room.tscn")
var dual_scene = preload("res://scenes/dual_scene.tscn")

onready var multiplayer_config_ui = $Multiplayer_configure
onready var server_ip_address = $Multiplayer_configure/Server_ip_address

onready var device_local_ip_address = $Multiplayer_configure/Device_local_ip_address
onready var external_ip_address_label = $Multiplayer_configure/external_ip_address_label
onready var device_external_ip_address = $Multiplayer_configure/Device_external_ip_address

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")

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
		start()

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")

func _on_Create_server_pressed():
	multiplayer_config_ui.hide()
	Network.create_server()

	instanciate_object_at_root(dining_room_scene, get_tree().get_network_unique_id())

func _on_Join_server_pressed():
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
	multiplayer_config_ui.hide()
	Network.create_server()

	var dual_scene_handle = dual_scene.instance()
	get_node("/root/Main").add_child(dual_scene_handle)
	
	var left_pane_handle = get_node("/root/Main/DualScene/LeftPane")
	var right_pane_handle = get_node("/root/Main/DualScene/RightPane")

	var _dining_room_scene_handle = instanciate_object(dining_room_scene, get_tree().get_network_unique_id(), left_pane_handle)
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
