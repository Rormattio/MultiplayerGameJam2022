extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 2

var server = null
var client = null

var ip_address = ""

func _ready() -> void:
	var local_addresses = IP.get_local_addresses()
	print("local_addresses = ", local_addresses)
	for ip in local_addresses:
		if (ip.find(":") == -1) and not (ip.begins_with("192.168.") and ip.ends_with(".1")): # let's not print ipv6 ips, nor virtual wifi ip
			ip_address = ip
			break

	assert(ip_address != "")
	print("ip_address = ", ip_address)
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func create_server() -> void:
	print("create_server")
	server = NetworkedMultiplayerENet.new()
	var error = server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	if error != 0:
		print("error = ", error)
	get_tree().set_network_peer(server)

func join_server() -> void:
	print("join_server")
	client = NetworkedMultiplayerENet.new()
	var error = client.create_client(ip_address, DEFAULT_PORT)
	if error != 0:
		print("error = ", error)
	get_tree().set_network_peer(client)

func _connected_to_server() -> void:
	print("Successfully connected to the server")

func _server_disconnected() -> void:
	print("Disconnected from the server")
