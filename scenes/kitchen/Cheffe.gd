extends KinematicBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta: float) -> void:
	if is_network_master() and visible:
		# waiter is player 2/2
		pass # TODO: process events
