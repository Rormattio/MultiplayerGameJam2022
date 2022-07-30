extends KinematicBody2D

signal patron_clicked(Patron)

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
	var food_files = []
	for ingredient_name in Global.ingredient_names:
		food_files.append("res://assets/food/" + ingredient_name + ".png")

	for f in food_files:
		food_assets.append(load(f))

	state = State.WAITING_TO_ORDER
	hide_wanted_dish()
	wanted_dish = generate_dish()

	connect("input_event", self, "_on_Patron_input_event")

func _process(_delta):
	pass

func _on_Patron_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("patron_clicked", self)

func serve_dish(dish):
	# Move dish in front of patron
	$DishPosition.add_child(dish)
	dish.position = Vector2.ZERO
	dish.scale = Vector2(1.0/5.0, 1.0/5.0)
	dish.z_index = 100 # to be above the table
	# Advance state
	dish.state = dish.State.SERVED

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
