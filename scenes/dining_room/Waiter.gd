extends KinematicBody2D

enum WaiterState {
	WALKING,
	TAKING_COMMAND,
}
var state = WaiterState.WALKING
var speed = 400
var velocity = Vector2(0, 0)

func _ready():
	pass

func _process(_delta: float) -> void:
	if is_network_master() and visible:
		var x_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		var y_input = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		
		velocity = Vector2(x_input, y_input).normalized()	
		move_and_slide(velocity * speed)
