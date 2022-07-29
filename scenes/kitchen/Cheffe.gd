extends KinematicBody2D

var player_idx = 0 # *local* player index (eg there may be 2 local players in the server app)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta: float) -> void:
	if is_network_master() and visible:
		pass # TODO: process events
