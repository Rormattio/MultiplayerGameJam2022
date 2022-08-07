extends Node2D

signal close_command_popup()
signal serve_dish_pressed(patron)

const Order = preload("res://scenes/shared/Order.gd")

const MAX_WORDS_IN_ORDER = 4

var tray
onready var command_gui = $Command_GUI
onready var wordlist = $Command_GUI/WordList
onready var clear_order = $Command_GUI/ClearOrder
onready var send_order = $Command_GUI/SendOrder
onready var order_preview = $Command_GUI/OrderPreview

var table = null
var current_order = []

enum State {
	VISIBLE,
	NOT_VISIBLE,
}
var state

func _ready():
	# Command GUI
	_set_visible(false)
	send_order.connect("pressed", self, "_on_SendOrder_pressed")
	send_order.disabled = true
	clear_order.connect("pressed", self, "_on_ClearOrder_pressed")
	wordlist.connect("item_selected", self, "_on_WordList_item_selected")
	wordlist.max_columns = 3
	build_word_list()

	for control_box in $Background.get_children():
		control_box.connect("gui_input", self, "_on_Background_gui_input")

func _set_visible(_visible):
	visible = _visible
	if _visible:
		state = State.VISIBLE
	else:
		state = State.NOT_VISIBLE

func pop_up(o_table):
	_set_visible(true)
	current_order.clear()
	order_preview.text = ""
	table = o_table

func pop_down():
	### this function should be called by outer class DiningRoomLevel
	### if you need to "pop_down" from the context of DiningRoom, call emit_signal("close_command_popup") instead
	_set_visible(false)
	order_preview.text = ""
	current_order.clear()
	for patron in table.patrons_around:
		patron.command_avatar.visible = false
	table = null

func _process(_delta):
	pass

func build_word_list_v0():
	var colors = [
		["violet", "purple", "pink",],
		["vermilion", "scarlet", "red",],
		["blue", "green", "bluish",],
		["yellow", "amber", "cream",],
		["colourful",],
		["brillig",],
		["aprelot",],
	]

	var forms = [
		["round", "spherical"],
		["curvaceous", "shapely",],
		["elongated", "oblong",],
		["positive", "happy", "friendly",],
		["negative", "unfriendly", "antagonistic", "adverse",],
		["expressive", "visceral",],
		["squishy", "soft",],
		["scrumptuous",],
		["cromulent",],
	]

	var things = [
		"kebab",
		"fruit",
		"poppycock",
		"malarkey",
		"galimatias",
		"fadoodle",
		"gobbledygook",
		"thingy",
	]

	var chosen_color_words = []
	var chosen_form_words = []
	var chosen_thing_words = []

	for w in colors:
		chosen_color_words.append(Global.rand_array(w))
	chosen_color_words.shuffle()

	for w in forms:
		chosen_form_words.append(Global.rand_array(w))
	chosen_form_words.shuffle()

	chosen_thing_words = things
	chosen_thing_words.shuffle()

	for i in range(max(chosen_color_words.size(), max(chosen_form_words.size(), chosen_thing_words.size()))):
		if i < chosen_color_words.size():
			wordlist.add_item(chosen_color_words[i])
		else:
			wordlist.add_item("")

		if i < chosen_form_words.size():
			wordlist.add_item(chosen_form_words[i])
		else:
			wordlist.add_item("")

		if i < chosen_thing_words.size():
			wordlist.add_item(chosen_thing_words[i])
		else:
			wordlist.add_item("")

func build_word_list():
	var _seed = randi()

	var	keyword_list = Global.make_keyword_list(_seed)

	keyword_list.sort()

	for kw in keyword_list:
		wordlist.add_item(kw)

	for idx in range(wordlist.get_item_count()):
		wordlist.set_item_tooltip_enabled(idx, false)


func get_current_order_text() -> String:
	return order_preview.text.strip_edges()

func get_current_order_word_count() -> int:
	return current_order.size()

func waiter_send_order(order: Order):
	Global.logger("sent order " + str(order))
	Global.waiter_send_command(order)

var word_list_disabled = false

func _on_WordList_item_selected(index: int):
	wordlist.unselect_all()

	if word_list_disabled:
		return

	if get_current_order_word_count() == MAX_WORDS_IN_ORDER:
		return

	var word = wordlist.get_item_text(index)
	current_order.append(word)
	order_preview.text += " " + word
	send_order.disabled = false

func _on_SendOrder_pressed():
	var order = Order.new()
	order.init(get_current_order_text())
	waiter_send_order(order)
	assert(len(table.patrons_around) == 1)
	var patron = table.patrons_around[0]
	patron.set_state(patron.State.WAITING_TO_EAT)
	emit_signal("close_command_popup")

func _on_ClearOrder_pressed():
	order_preview.text = ""
	current_order.clear()
	send_order.disabled = true

func _on_Background_gui_input(event: InputEvent):
	var mouse_pos = event.position
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("close_command_popup")

func update_waiter_actions():

	# can waiter take an order ?
	var can_send_command = false
	for patron in table.patrons_around:
		if (patron.state == patron.State.WAITING_TO_ORDER) or (patron.state == patron.State.ORDERING):
			can_send_command = true
#	$Command_GUI/WordList.disabled = not can_send_command # NOTE: item_list has no disabled, so we interrupt their event instead
	word_list_disabled = not can_send_command
	$Command_GUI/ClearOrder.disabled = not can_send_command
	$Command_GUI/SendOrder.disabled = not can_send_command

	# can waiter give a dish
	var can_give_dish = false
	for patron in table.patrons_around:
		if (patron.state == patron.State.WAITING_TO_EAT):
			can_give_dish = true
	$DialogueGiveDish.visible = can_give_dish

	# can waiter give a dish
	var can_farewell = false
	for patron in table.patrons_around:
		if (patron.state == patron.State.SHOW_DISH_SCORE):
			can_farewell = true
	$DialogueFarewell.visible = can_farewell

func _on_Farewell_button_up():
	assert(len(table.patrons_around) == 1)
	var patron = table.patrons_around[0]
	patron.set_state(patron.State.LEAVING)

func _on_GiveDish_button_up():
	assert(len(table.patrons_around) == 1)
	var patron = table.patrons_around[0]
	emit_signal("serve_dish_pressed", patron)
