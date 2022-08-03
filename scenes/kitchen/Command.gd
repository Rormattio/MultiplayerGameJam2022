extends Node2D

signal close_command(id)
signal send_dish_pressed(command)

var order


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Button_button_up():
	emit_signal("close_command", name)

func _on_SendDish_button_up():
	emit_signal("send_dish_pressed", self)
