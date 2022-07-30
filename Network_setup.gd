extends Node

var kitchen_scene = preload("res://scenes/kitchen/Kitchen.tscn")
var dining_room_scene = preload("res://scenes/dining_room/Dining_room.tscn")

onready var multiplayer_config_ui = $Multiplayer_configure
onready var server_ip_address = $Multiplayer_configure/Server_ip_address

onready var device_ip_address = $Multiplayer_configure/Device_ip_address

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")

	device_ip_address.text = Network.ip_address

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")

	if is_network_master():
		start()

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")

func _on_Create_server_pressed():
	multiplayer_config_ui.hide()
	Network.create_server()

	instanciate_object(dining_room_scene, get_tree().get_network_unique_id())

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

func _connected_to_server() -> void:
	instanciate_object(kitchen_scene, get_tree().get_network_unique_id())

	start()

func instanciate_object(scene, id):
	var p = scene.instance()
	p.name = str(id)
	p.set_network_master(id)
	get_node("/root/Main").add_child(p)

func start():
	print("start game")
