extends Node

const Dish = preload("res://Dish.gd")
const DishRenderer = preload("res://DishRenderer.gd")
const ReceivedDish = preload("ReceivedDish.gd")


signal patron_clicked(patron)
signal patron_leaves(patron)

onready var dish_wish = $CommandAvatar/DishWish
onready var dish_score = $CommandAvatar/DishScore
onready var dish_position = $CommandAvatar/DishPosition
onready var command_avatar = $CommandAvatar
onready var level_avatar = $LevelAvatar

enum State {
	ENTERING,
	WAITING_TO_ORDER,
	ORDERING, # state in zoomed-in view
	WAITING_TO_EAT,
	EATING,
	SHOW_DISH_SCORE, # state in zoomed-in view
	LEAVING,
	DELETE,
}

var patron_index
var speed = 200
var state
var wanted_dish # Repr
var dish_score_value
var destination
var level_avatar_is_visible
var command_avatar_is_visible
var sitting_at_table
var path_to_follow
var path_offset = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	command_avatar.patron = self
	level_avatar.patron = self
	level_avatar_is_visible = false
	command_avatar_is_visible = false

	wanted_dish = null
	hide_wanted_dish()
	hide_dish_score()

	dish_score_value = 0

	$EatTimer.connect("timeout", self, "_on_EatTimer_timeout")

func init():
	set_state(State.ENTERING)
	refresh_avatars_visible()

func _process(delta):
	match state:
		State.ENTERING:
			path_offset += speed*delta
			path_to_follow.set_offset(path_offset)
			var new_position = path_to_follow.get_position()
			if level_avatar.position == new_position:
				set_state(State.WAITING_TO_ORDER)
				path_offset -= speed*delta
			level_avatar.position = new_position
		State.LEAVING:
			path_offset -= speed*delta
			path_to_follow.set_offset(path_offset)
			var new_position = path_to_follow.get_position()
			if level_avatar.position == new_position:
				set_state(State.DELETE)
			level_avatar.position = new_position

func refresh_avatars_visible():
	set_avatars_visible(level_avatar_is_visible)

func set_avatars_visible(_level_avatar_is_visible):
	level_avatar_is_visible = _level_avatar_is_visible
	level_avatar.visible = _level_avatar_is_visible
	level_avatar.input_pickable = _level_avatar_is_visible

	var _command_avatar_is_visible = sitting_at_table.taking_commands
	assert(not (_level_avatar_is_visible and _command_avatar_is_visible))
	command_avatar_is_visible = _command_avatar_is_visible and (state > State.ENTERING) and (state < State.LEAVING)
	command_avatar.visible = command_avatar_is_visible
	command_avatar.input_pickable = command_avatar_is_visible

func serve_dish(dish):
	# Move dish in front of patron
	dish_position.add_child(dish)
	dish.position = Vector2.ZERO
	dish.scale = Vector2(1.0/4.0, 1.0/4.0)
	dish.z_index = 100 # to appear above the table
	# Advance state
	dish.set_state(dish.State.SERVED)
	set_state(State.EATING)

func set_state(a_state):
	if state != null:
		print("Patron.set_state ", State.keys()[state], " -> ", State.keys()[a_state])
	else:
		print("Patron.set_state ", State.keys()[a_state])
	match a_state:
		State.ENTERING:
			pass

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
			emit_signal("patron_leaves", self)

		State.DELETE:
			queue_free()

	state = a_state
	refresh_avatars_visible()

func compute_dish_score(wanted_dish : Dish, dish : Dish):
	assert(wanted_dish != null)
	assert(dish != null)
	var diffs = Dish.compute_difference(wanted_dish, dish)
	var score = diffs[0] + diffs[1] + diffs[2] + diffs[3]
	return score

func show_dish_score():
	dish_score.get_node("Label").text = str(dish_score_value)
	dish_score.show()

func hide_dish_score():
	dish_score.hide()

func _on_EatTimer_timeout():
	var received_dish = dish_position.get_child(0) as ReceivedDish

	assert(wanted_dish != null)
	assert(received_dish != null)
	dish_score_value = compute_dish_score(wanted_dish, received_dish.dish)
	Global.patron_send_dish_score(received_dish.dish, dish_score_value)

	command_avatar.rotation = 0
	received_dish.queue_free()
	set_state(State.SHOW_DISH_SCORE)

func toggle_wanted_dish():
	if dish_wish.visible:
		hide_wanted_dish()
	else:
		show_wanted_dish()

func show_wanted_dish():
	dish_wish.show()

func hide_wanted_dish():
	dish_wish.hide()

func _decide_how_many_ingredients_for_dish():
	# TODO : We shouldn't use patron_index here but the order processing index
	var seq_len = 3
	var _min
	var _max
	if (patron_index < seq_len):
		_min = 1
		_max = 1
	elif (patron_index < seq_len * 2):
		_min = 1
		_max = 2
	elif (patron_index < seq_len * 3):
		_min = 2
		_max = 2
	elif (patron_index < seq_len * 4):
		_min = 2
		_max = 3
	elif (patron_index < seq_len * 5):
		_min = 3
		_max = 3
	elif (patron_index < seq_len * 6):
		_min = 3
		_max = 4
	else:
		_min = 4
		_max = 4

	print("_decide_how_many_ingredients_for_dish : ", patron_index, " -> ", _min, ", ", _max)
	return [_min, _max]

func generate_dish() -> Dish:
	var random_dish = Dish.new()

	var minmax = _decide_how_many_ingredients_for_dish()
	random_dish.randomize_with_min_max_ingredients(minmax[0], minmax[1])
	random_dish.debug_print()
	var random_dish_node = DishRenderer.render_dish(random_dish)
	random_dish_node.scale = Vector2(2, 2)
	# TODO remove childs
	assert(dish_wish.get_node("Sprite").get_child_count() == 0)
	dish_wish.get_node("Sprite").add_child(random_dish_node)

	return random_dish
