extends Control

var cheffe_scene = preload("res://scenes/kitchen/Cheffe.tscn")
var waiter_scene = preload("res://scenes/dining_room/Waiter.tscn")

onready var multiplayer_config_ui = $Multiplayer_configure
onready var server_ip_address = $Multiplayer_configure/Server_ip_address

onready var device_ip_address = $Multiplayer_configure/Device_ip_address

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")

	device_ip_address.text = Network.ip_address

	Global.connect("waiter_command_sent", self, "_on_WaiterCommand_Sent")
	Global.connect("cheffe_dish_sent", self, "_on_CheffeDish_Sent")

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")

	if is_network_master():
		start()

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")

func _on_Create_server_pressed():
	multiplayer_config_ui.hide()
	Network.create_server()

	create_player(waiter_scene, get_tree().get_network_unique_id())

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
	create_player(cheffe_scene, get_tree().get_network_unique_id())

	start()

func create_player(scene, id):
	var p = scene.instance()
	p.name = str(id)
	p.set_network_master(id)
	add_child(p)

func start():
	print("start game")

func _on_WaiterCommand_Sent(command):
	print("waiter command ", command)

func _on_CheffeDish_Sent(dish):
	print("cheffe dish ", dish)
