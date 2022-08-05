extends KinematicBody2D

signal patron_avatar_level_clicked()

var patron

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_LevelAvatar_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if patron.state > patron.State.ENTERING and patron.state < patron.State.LEAVING:
			emit_signal("patron_avatar_level_clicked", patron)
