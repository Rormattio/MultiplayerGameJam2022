extends KinematicBody2D

signal patron_avatar_level_clicked()

var patron
var animated_sprite

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

func _on_LevelAvatar_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_LevelAvatar_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
