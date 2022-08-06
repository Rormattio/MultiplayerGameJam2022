extends Node2D

class_name Command

signal close_command(id)
signal send_dish_pressed(command)

var order
var type

enum Type {
	ACTIVE_COMMAND,
	HISTORY_COMMAND,
}

static func instance_command_scene(_type, _order) -> Command:
	var command_scene = load("res://scenes/kitchen/Command.tscn")
	var command = command_scene.instance()
	command.type = _type
	match _type:
		Type.ACTIVE_COMMAND:
			pass
		Type.HISTORY_COMMAND:
			command.get_node("Close").visible = false
			command.get_node("SendDish").visible = false
	command.order = _order
	return command

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Button_button_up():
	emit_signal("close_command", name)

func _on_SendDish_button_up():
	emit_signal("send_dish_pressed", self)
