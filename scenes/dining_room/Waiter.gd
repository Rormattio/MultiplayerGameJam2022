extends KinematicBody2D

func _ready():
	$SendCommand.connect("pressed", self, "_on_ButtonPressed")

func _process(delta: float) -> void:
	pass

func _on_ButtonPressed():
	var command = $CommandInput.text
	Global.waiter_send_command(command)
