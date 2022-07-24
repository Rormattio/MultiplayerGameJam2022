extends KinematicBody2D

const speed = 400

var velocity = Vector2(0, 0)
puppet var puppet_position = Vector2(0, 0) setget puppet_position_set

onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta: float) -> void:
	if is_network_master() and visible:
		var x_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		var y_input = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		
		velocity = Vector2(x_input, y_input).normalized()	
		move_and_slide(velocity * speed)
		#look_at(get_global_mouse_position())

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
