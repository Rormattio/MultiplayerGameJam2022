extends Node

const Dish = preload("res://Dish.gd")
const DishRenderer = preload("res://DishRenderer.gd")
const ReceivedDish = preload("ReceivedDish.gd")

signal patron_leaves(patron)
signal patron_enters_room()
signal patron_exits_room()
signal patron_state_changed(patron)

onready var dish_wish = $CommandAvatar/DishWish
onready var dish_score = $CommandAvatar/DishScore
onready var dish_position = $CommandAvatar/DishPosition
onready var command_avatar = $CommandAvatar
onready var level_avatar = $LevelAvatar

class_name Patron

enum State {
	ENTERING_BEHIND_WINDOW,
	ENTERING,
	WAITING_TO_ORDER,
	ORDERING,
	WAITING_TO_EAT,
	EATING,
	SHOW_DISH_SCORE,
	LEAVING,
	LEAVING_BEHIND_WINDOW,
	DELETE,
}

var PATRON_SPRITE_NAMES = [
	"frog",
	"duck",
	"auronron",
	"bertmo",
	"fmdkdd",
	"fromage_chaud",
]

var PATRON_HAS_ANIM = {
	"frog": true,
	"duck": true,
	"auronron": false,
	"bertmo": false,
	"fmdkdd": false,
	"fromage_chaud": false,
}	

const BEHIND_WINDOW_TINT = Color("#1a2b3b")
const IN_ROOM_TINT = Color("#ffffff")

var patron_index
var speed = 200
var state
var wanted_dish # Repr
var destination
var level_avatar_is_visible
var command_avatar_is_visible
var sitting_at_table
var path_to_follow
var path_offset = 0.0
var dish_score_value
var ingredient_diffs
var sprite_name

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
	set_state(State.ENTERING_BEHIND_WINDOW)
	refresh_avatars_visible()

	var sprite_idx = patron_index % len(PATRON_SPRITE_NAMES)
	sprite_name = PATRON_SPRITE_NAMES[sprite_idx]
	var animated_sprite
	var avatars = [level_avatar, command_avatar]
	for avatar_idx in range(len(avatars)):
		var avatar = avatars[avatar_idx]
		animated_sprite = AnimatedSprite.new()
		if avatar_idx == 1:
			animated_sprite.scale.x = 3
			animated_sprite.scale.y = 3
		avatar.add_child(animated_sprite)
		avatar.animated_sprite = animated_sprite
		animated_sprite.frames = SpriteFrames.new()
		animated_sprite.frames.clear_all()
		animated_sprite.frames.add_animation("idle")
		animated_sprite.frames.add_animation("walk")
		var animation_size
		if PATRON_HAS_ANIM[sprite_name]:
			animation_size = 4
		else:
			animation_size = 1
		for frame_idx in range(animation_size):
			var sprite = load("res://assets/misc/" + sprite_name + str(frame_idx) + ".png")
			assert(sprite != null)
			animated_sprite.frames.add_frame("walk", sprite)
			if frame_idx == 0:
				animated_sprite.frames.add_frame("idle", sprite)
	level_avatar.animated_sprite.play("walk")
	command_avatar.animated_sprite.play("idle")

func _physics_process(delta):
	match state:
		State.ENTERING_BEHIND_WINDOW:
			level_avatar.position.x += 2
			if level_avatar.position.x >= 550:
				set_state(State.ENTERING)

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
			var reached_path_end = level_avatar.position == new_position
			level_avatar.position = new_position
			if reached_path_end:
				set_state(State.LEAVING_BEHIND_WINDOW)

		State.LEAVING_BEHIND_WINDOW:
			level_avatar.position.x += 2
			if level_avatar.position.x >= 1400:
				set_state(State.DELETE)


func refresh_avatars_visible():
	set_avatars_visible(level_avatar_is_visible)

func set_avatars_visible(_level_avatar_is_visible):
	level_avatar_is_visible = _level_avatar_is_visible
	level_avatar.visible = _level_avatar_is_visible
	level_avatar.input_pickable = _level_avatar_is_visible

	var _command_avatar_is_visible = sitting_at_table.is_popped_up
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
	assert(state != a_state)
	match a_state:
		State.ENTERING_BEHIND_WINDOW:
			level_avatar.z_index = -1
			level_avatar.modulate = BEHIND_WINDOW_TINT

		State.ENTERING:
			emit_signal("patron_enters_room")
			level_avatar.z_index = 0
			level_avatar.modulate = IN_ROOM_TINT
			pass

		State.WAITING_TO_ORDER:
			level_avatar.animated_sprite.play("idle")
			wanted_dish = generate_dish()
			show_wanted_dish()

		State.ORDERING:
			pass

		State.WAITING_TO_EAT:
			hide_wanted_dish()

		State.EATING:
			hide_wanted_dish()
			$EatTimer.start()

		State.SHOW_DISH_SCORE:
			show_dish_score()

		State.LEAVING:
			hide_dish_score()
			level_avatar.animated_sprite.play("walk")
			emit_signal("patron_leaves", self)

		State.LEAVING_BEHIND_WINDOW:
			emit_signal("patron_exits_room")
			level_avatar.position.y = 100
			level_avatar.z_index = -1
			level_avatar.modulate = BEHIND_WINDOW_TINT

		State.DELETE:
			queue_free()

	state = a_state
	emit_signal("patron_state_changed", self)
	refresh_avatars_visible()

func compute_dish_score(wanted_dish : Dish, dish : Dish):
	assert(wanted_dish != null)
	assert(dish != null)
	var diffs = Dish.compute_difference(wanted_dish, dish)
	var score = 0
	for i in range(4):
		if diffs[i] != -1:
			score += 2*diffs[i]
		else:
			diffs[i] = 2 # sets back to 2 to have the correct smileys
	return [score, diffs]

func show_dish_score():
	show_wanted_dish()
	dish_score.render(ingredient_diffs, dish_score_value)

func hide_dish_score():
	dish_score.hide()

func _on_EatTimer_timeout():
	var received_dish = dish_position.get_child(0) as ReceivedDish

	assert(wanted_dish != null)
	assert(received_dish != null)
	var res = compute_dish_score(wanted_dish, received_dish.dish)
	dish_score_value = res[0]
	ingredient_diffs = res[1]
	Global.patron_send_dish_score(received_dish.dish.serialize(), dish_score_value, received_dish.order.serialize(), ingredient_diffs)
	Global.send_score(dish_score)
	
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
	# TODO remove childs if necessary
	assert(dish_wish.get_node("Sprite").get_child_count() == 0)
	dish_wish.get_node("Sprite").add_child(random_dish_node)

	var ingredients_node = DishRenderer.render_ingredients(random_dish, 72)
	#ingredients_node.scale = Vector2(2, 2)
	assert(dish_wish.get_node("Ingredients").get_child_count() == 0)
	dish_wish.get_node("Ingredients").add_child(ingredients_node)

	return random_dish

var PLAY_VOICE_PROBABILITY = 1.0

func play_hello_sometimes():
	if randf() <= PLAY_VOICE_PROBABILITY:
		var stream = AudioSfx.get_hello_stream_for_patron(sprite_name)
		if stream != null:
			$AudioStreamPlayer.stream = stream
			$AudioStreamPlayer.play()

func play_nomnom_sometimes():
	if randf() <= PLAY_VOICE_PROBABILITY:
		var stream = AudioSfx.get_nomnom_stream_for_patron(sprite_name)
		if stream != null:
			$AudioStreamPlayer.stream = stream
			$AudioStreamPlayer.play()

func play_bye_sometimes():
	if randf() <= PLAY_VOICE_PROBABILITY:
		var stream = AudioSfx.get_bye_stream_for_patron(sprite_name)
		if stream != null:
			$AudioStreamPlayer.stream = stream
			$AudioStreamPlayer.play()
