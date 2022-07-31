extends Node

signal patron_clicked(patron)
signal patron_leaves(patron)

onready var dish_wish = $CommandAvatar/DishWish
onready var dish_score = $CommandAvatar/DishScore
onready var dish_position = $CommandAvatar/DishPosition
onready var command_avatar = $CommandAvatar
onready var level_avatar = $LevelAvatar

var food_assets = []

enum State {
	ENTERING,
	WAITING_TO_ORDER,
	ORDERING, # state in zoomed-in view
	WAITING_TO_EAT,
	EATING,
	SHOW_DISH_SCORE, # state in zoomed-in view
	LEAVING,
}

var state
var wanted_dish
var dish_score_value
var destination
var level_avatar_is_visible

# Called when the node enters the scene tree for the first time.
func _ready():
	var food_files = []
	for ingredient_name in Global.base_ingredient_names:
		food_files.append("res://assets/food/" + ingredient_name + ".png")

	for f in food_files:
		food_assets.append(load(f))

	command_avatar.patron = self
	level_avatar_is_visible = true
	set_level_avatar_visible(level_avatar_is_visible)

	wanted_dish = null
	hide_wanted_dish()
	hide_dish_score()
	set_state(State.ENTERING)

	dish_score_value = 0

	connect("input_event", self, "_on_Patron_input_event")

	$EatTimer.connect("timeout", self, "_on_EatTimer_timeout")
	$EnteringTimer.connect("timeout", self, "_on_EnteringTimer_timeout")
	$LeavingTimer.connect("timeout", self, "_on_LeavingTimer_timeout")
	
	command_avatar.connect("patron_avatar_command_clicked", self, "_on_any_avatar_clicked")
	level_avatar.connect("patron_avatar_level_clicked", self, "_on_any_avatar_clicked")

func set_level_avatar_visible(_visible):
	level_avatar_is_visible = _visible
	level_avatar.visible = _visible
	level_avatar.input_pickable = _visible
	var command_avatar_is_visible = (not _visible) and (state > State.ENTERING) and (state < State.LEAVING)
	command_avatar.visible = command_avatar_is_visible
	command_avatar.input_pickable = command_avatar_is_visible

func serve_dish(dish):
	# Move dish in front of patron
	dish_position.add_child(dish)
	dish.position = Vector2.ZERO
	dish.scale = Vector2(1.0/4.0, 1.0/4.0)
	dish.z_index = 100 # to appear above the table
	# Advance state
	dish.state = dish.State.SERVED
	set_state(State.EATING)

func set_state(a_state):
	match a_state:
		State.ENTERING:
			$EnteringTimer.start()

		State.ORDERING:
			wanted_dish = generate_dish()
			show_wanted_dish()
			
		State.WAITING_TO_EAT:
			pass
			
		State.EATING:
			hide_wanted_dish()
			$EatTimer.start()

		State.SHOW_DISH_SCORE:
			show_dish_score()
		
		State.LEAVING:
			$LeavingTimer.start()

	state = a_state
	set_level_avatar_visible(level_avatar_is_visible) # refresh, in case we changed state

func compute_dish_score(wanted_dish, dish):
	# TODO
	return 5

func show_dish_score():
	dish_score.get_node("Label").text = str(dish_score_value)
	dish_score.show()

func hide_dish_score():
	dish_score.hide()

func _on_EnteringTimer_timeout():
	set_state(State.WAITING_TO_ORDER)
	level_avatar.position = destination

func _on_LeavingTimer_timeout():
	emit_signal("patron_leaves", self)
	queue_free()

func _on_EatTimer_timeout():
	var dish = dish_position.get_child(0)

	dish_score_value = compute_dish_score(wanted_dish, dish)
	Global.patron_send_dish_score(dish.dish, dish_score_value)

	command_avatar.rotation = 0
	dish.queue_free()
	set_state(State.SHOW_DISH_SCORE)

func _on_any_avatar_clicked():
	emit_signal("patron_clicked", self)

func toggle_wanted_dish():
	if dish_wish.visible:
		hide_wanted_dish()
	else:
		show_wanted_dish()

func show_wanted_dish():
	dish_wish.show()

func hide_wanted_dish():
	dish_wish.hide()

func generate_dish():
	var food_img = Global.rand_array(food_assets)
	dish_wish.get_node("Sprite").texture = food_img
