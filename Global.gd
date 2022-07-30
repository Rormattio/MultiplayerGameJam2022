extends Node

signal cheffe_dish_sent(dish)
signal waiter_command_sent(command)

func _ready():
	randomize()

func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

func waiter_send_command(command):
	rpc("on_waiter_command", command)

remote func on_waiter_command(command):
	emit_signal("waiter_command_sent", command)

func cheffe_send_dish(dish):
	rpc("on_cheffe_dish", dish)

remote func on_cheffe_dish(dish):
	emit_signal("cheffe_dish_sent", dish)
