extends Node

signal upnp_completed(error)

var SERVER_PORT = Network.DEFAULT_PORT
var thread = null
var upnp = null
var delete_mapping = false
var mapped_port
var external_ip_address = null

func _upnp_setup(server_port):
	# UPNP queries take some time.
	upnp = UPNP.new()
	var err = upnp.discover()

	if err != UPNP.UPNP_RESULT_SUCCESS:
		push_error(str(err))
		emit_signal("upnp_completed", err)
		return

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		err = upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		if err != UPNP.UPNP_RESULT_SUCCESS:
			push_error(str(err))
			emit_signal("upnp_completed", err)
			return

		err = upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		if err != UPNP.UPNP_RESULT_SUCCESS:
			push_error(str(err))
			emit_signal("upnp_completed", err)
			return

		external_ip_address = upnp.get_gateway().query_external_address()

		delete_mapping = true
		mapped_port = server_port

		emit_signal("upnp_completed", UPNP.UPNP_RESULT_SUCCESS)

func _ready():
	thread = Thread.new()
	thread.start(self, "_upnp_setup", SERVER_PORT)

func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	if delete_mapping:
		var gateway = upnp.get_gateway()
		if gateway and gateway.is_valid_gateway():
			gateway.delete_port_mapping(mapped_port, "UDP")
			gateway.delete_port_mapping(mapped_port, "TCP")
	thread.wait_to_finish()
