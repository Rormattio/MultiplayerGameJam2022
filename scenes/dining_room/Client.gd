extends KinematicBody2D

enum ClientState {
#	ENTERING,
	WAITING_TO_ORDER,
	WAITING_TO_EAT,
	EATING,
#	LEAVING,
}

var wants_commmand = null
var state = ClientState.WAITING_TO_ORDER
var in_current_state_since = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_click():
	if state == ClientState.WAITING_TO_ORDER:
		pass # TODO
	elif state == ClientState.WAITING_TO_EAT:
		pass # TODO
	elif state == ClientState.EATING:
		pass # nothing to be done
	else:
		assert(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
