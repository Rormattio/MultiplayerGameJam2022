extends KinematicBody2D

signal patron_avatar_command_clicked()

var patron
var sway_t = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	if patron.state == patron.State.EATING:
		sway_t += 0.2
		rotation = 0.3*sin(sway_t)

func _on_CommandAvatar_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("patron_avatar_command_clicked")
