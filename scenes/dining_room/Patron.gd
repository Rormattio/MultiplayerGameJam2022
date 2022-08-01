extends Node

const Dish = preload("res://Dish.gd")
const DishRenderer = preload("res://DishRenderer.gd")


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
}

var state
var wanted_dish # Repr
var dish_score_value
var destination
var level_avatar_is_visible
var command_avatar_is_visible
var sitting_at_table

# Called when the node enters the scene tree for the first time.
func _ready():
	command_avatar.patron = self
	level_avatar_is_visible = false
	command_avatar_is_visible = false

	wanted_dish = null
	hide_wanted_dish()
	hide_dish_score()

	dish_score_value = 0

	connect("input_event", self, "_on_Patron_input_event")

	$EatTimer.connect("timeout", self, "_on_EatTimer_timeout")
	$EnteringTimer.connect("timeout", self, "_on_EnteringTimer_timeout")
	$LeavingTimer.connect("timeout", self, "_on_LeavingTimer_timeout")
	
	command_avatar.connect("patron_avatar_command_clicked", self, "_on_any_avatar_clicked")
	level_avatar.connect("patron_avatar_level_clicked", self, "_on_any_avatar_clicked")
	
func init():
	set_state(State.ENTERING)
	refresh_avatars_visible()

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
	dish.state = dish.State.SERVED
	set_state(State.EATING)

func set_state(a_state):
	if state != null:
		print("Patron.set_state ", State.keys()[state], " -> ", State.keys()[a_state])
	else:
		print("Patron.set_state ", State.keys()[a_state])
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
			emit_signal("patron_leaves", self)
			$LeavingTimer.start()

	state = a_state
	refresh_avatars_visible()

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
	var random_dish = Dish.new()
	random_dish.randomize()
	random_dish.debug_print()
	var random_dish_node = DishRenderer.render_dish(random_dish)
	random_dish_node.scale = Vector2(2, 2)
	# TODO remove childs
	assert(dish_wish.get_node("Sprite").get_child_count() == 0)
	dish_wish.get_node("Sprite").add_child(random_dish_node)
