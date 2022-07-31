extends Node2D

const MAX_WORDS_IN_ORDER = 4

var tray
onready var command_gui = $Command_GUI
onready var wordlist = $Command_GUI/WordList
onready var clear_order = $Command_GUI/ClearOrder
onready var send_order = $Command_GUI/SendOrder
onready var order_preview = $Command_GUI/OrderPreview

var patrons = []

var current_order = []

func _ready():
	# Command GUI
	command_gui.visible = false
	send_order.connect("pressed", self, "_on_SendOrder_pressed")
	send_order.disabled = true
	clear_order.connect("pressed", self, "_on_ClearOrder_pressed")
	wordlist.connect("item_selected", self, "_on_WordList_item_selected")
	wordlist.max_columns = 3
	build_word_list()

	$Trash.connect("gui_input", self, "_on_Trash_gui_input")

func pop_up(patrons):
	current_order.clear()
	order_preview.text = ""
	patrons.clear()

	for patron in patrons:
		patron.connect("patron_clicked", self, "_on_Patron_clicked")
		patrons.append(patron)
	
func pop_down():
	for patron in patrons:
		patron.disconnect("patron_clicked", self, "_on_Patron_clicked")
	patrons.clear()
	
func _process(_delta):
	pass

func build_word_list():
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

func get_current_order() -> String:
	return order_preview.text.strip_edges()

func get_current_order_word_count() -> int:
	return current_order.size()

func send_order(order):
	print("sent order ", order)
	Global.waiter_send_command(order)

func _on_WordList_item_selected(index: int):
	wordlist.unselect_all()

	if get_current_order_word_count() == MAX_WORDS_IN_ORDER:
		return

	var word = wordlist.get_item_text(index)
	current_order.append(word)
	order_preview.text += " " + word
	send_order.disabled = false

func _on_SendOrder_pressed():
	var order = get_current_order()
	send_order(order)
	send_order.disabled = true
	order_preview.text = ""
	current_order.clear()

func _on_ClearOrder_pressed():
	order_preview.text = ""
	current_order.clear()
	send_order.disabled = true

func _on_Patron_clicked(patron):
	if tray.selected_dish != null and patron.state == patron.State.ORDERING:
		var dish = tray.selected_dish
		tray.remove_dish(dish)
		patron.serve_dish(dish)
	else:
		patron._on_Patron_clicked()

func _on_Trash_clicked():
	if tray.selected_dish != null:
		var dish = tray.selected_dish
		tray.remove_dish(dish)
		dish.queue_free()

func _on_Trash_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		_on_Trash_clicked()
