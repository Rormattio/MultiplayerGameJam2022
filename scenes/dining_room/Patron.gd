extends KinematicBody2D

var food_assets = []

enum State {
#	ENTERING,
	WAITING_TO_ORDER,
	WAITING_TO_EAT,
	EATING,
#	LEAVING,
}

var state
var wanted_dish
var in_current_state_since = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var food_files = [
		"res://assets/food/black_forest_hole.png",
		"res://assets/food/blue_banana.png",
		"res://assets/food/blue_banana.png",
		"res://assets/food/ghosts.png",
		"res://assets/food/springs.png",
		"res://assets/food/grumpy_puree.png",
		"res://assets/food/happy_puree.png",
		"res://assets/food/mighty_puree.png",
		"res://assets/food/smirky_puree.png",
		"res://assets/food/worried_puree.png",
	]

	for f in food_files:
		food_assets.append(load(f))

	state = State.WAITING_TO_ORDER
	hide_wanted_dish()
	wanted_dish = generate_dish()

func _process(delta):
	pass

func _on_Patron_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		_on_Patron_pressed()

func _on_Patron_pressed():
	if state == State.WAITING_TO_ORDER:
		toggle_wanted_dish()
	elif state == State.WAITING_TO_EAT:
		pass # TODO
	elif state == State.EATING:
		pass # nothing to be done
	else:
		assert(false)


func toggle_wanted_dish():
	if $DishWish.visible:
		hide_wanted_dish()
	else:
		show_wanted_dish()

func show_wanted_dish():
	$DishWish.show()

func hide_wanted_dish():
	$DishWish.hide()

func generate_dish():
	var food_img = food_assets[randi() % food_assets.size()]
	$DishWish/Sprite.texture = food_img
