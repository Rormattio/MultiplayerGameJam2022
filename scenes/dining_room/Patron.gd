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

var sway_t

# Called when the node enters the scene tree for the first time.
func _ready():
	var food_files = []
	for ingredient_name in Global.ingredient_names:
		food_files.append("res://assets/food/" + ingredient_name + ".png")

	for f in food_files:
		food_assets.append(load(f))

	hide_wanted_dish()
	set_state(State.WAITING_TO_ORDER)

	connect("input_event", self, "_on_Patron_input_event")

	$EatTimer.connect("timeout", self, "_on_EatTimer_timeout")

	sway_t = 0

func _physics_process(_delta):
	if state == State.EATING:
		sway_t += 0.2
		rotation = 0.3*sin(sway_t)

func _on_Patron_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("patron_clicked", self)

func serve_dish(dish):
	# Move dish in front of patron
	$DishPosition.add_child(dish)
	dish.position = Vector2.ZERO
	dish.scale = Vector2(1.0/5.0, 1.0/5.0)
	dish.z_index = 100 # to appear above the table
	# Advance state
	dish.state = dish.State.SERVED
	set_state(State.EATING)

func set_state(a_state):
	match a_state:
		State.WAITING_TO_ORDER:
			wanted_dish = generate_dish()
			show_wanted_dish()

		State.EATING:
			hide_wanted_dish()
			$EatTimer.start()

	state = a_state

func _on_EatTimer_timeout():
	var dish = $DishPosition.get_child(0)
	dish.queue_free()
	rotation = 0
	set_state(State.WAITING_TO_ORDER)

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
