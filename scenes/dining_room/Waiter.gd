extends KinematicBody2D

onready var send_command = $SendCommand
onready var command_input = $CommandInput

func _ready():
	send_command.connect("pressed", self, "_on_ButtonPressed")

func _process(delta: float) -> void:
	pass

func _on_ButtonPressed():
	var command = command_input.text
	Global.waiter_send_command(command)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
