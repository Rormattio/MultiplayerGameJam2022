extends KinematicBody2D

enum WaiterState {
	WALKING,
	TAKING_COMMAND,
}

onready var sprite = $Sprite

var state = WaiterState.WALKING
var speed = 400
const speed_min = 0
const speed_increase = 20
const speed_max = 500
var velocity = Vector2(0, 0)

func _ready():
	pass

func _physics_process(_delta: float) -> void:
	if is_network_master() and visible:
		var x_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		var y_input = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

		velocity = Vector2(x_input, y_input).normalized()

		if velocity.length() > 0:
			speed += speed_increase
			if speed >= speed_max:
				speed = speed_max
		else:
			speed = speed_min

		move_and_slide(velocity * speed)

		if velocity.length() > 0:
			if abs(velocity.x) >= abs(velocity.y):
				if velocity.x < 0:
					sprite.play("walk_left")
				else:
					sprite.play("walk_right")
			else:
				if velocity.y < 0:
					sprite.play("walk_up")
				else:
					sprite.play("walk_down")
		else:
			sprite.stop()
