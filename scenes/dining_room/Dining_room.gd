extends Node2D

var waiter_scene = preload("res://scenes/dining_room/Waiter.tscn")

onready var tray = $Tray

var waiter

func _ready():
	Global.connect("cheffe_dish_sent", self, "_on_CheffeDish_Sent")

	$SendOrder.connect("pressed", self, "_on_SendOrder_pressed")
	$SendOrder.disabled = true

	$ClearOrder.connect("pressed", self, "_on_ClearOrder_pressed")

	$WordList.connect("item_selected", self, "_on_WordList_item_selected")
	$OrderPreview.text = ""

	waiter = waiter_scene.instance()
	add_child(waiter)

	$Trash.connect("gui_input", self, "_on_Trash_gui_input")

	$WordList.max_columns = 3

	build_word_list()

	$Patron.connect("patron_clicked", self, "_on_Patron_clicked")
	$Patron2.connect("patron_clicked", self, "_on_Patron_clicked")
	$Patron3.connect("patron_clicked", self, "_on_Patron_clicked")

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

	for w in forms:
		chosen_form_words.append(Global.rand_array(w))

	chosen_thing_words = things

	for i in range(max(chosen_color_words.size(), max(chosen_form_words.size(), chosen_thing_words.size()))):
		if i < chosen_color_words.size():
			$WordList.add_item(chosen_color_words[i])
		else:
			$WordList.add_item("")

		if i < chosen_form_words.size():
			$WordList.add_item(chosen_form_words[i])
		else:
			$WordList.add_item("")

		if i < chosen_thing_words.size():
			$WordList.add_item(chosen_thing_words[i])
		else:
			$WordList.add_item("")


func _on_CheffeDish_Sent(dish):
	print("cheffe sends dish ", dish)
	tray.add_dish(dish)

func get_current_order() -> String:
	return $OrderPreview.text.strip_edges()

func send_order(order):
	print("sent order ", order)
	Global.waiter_send_command(order)

func _on_WordList_item_selected(index: int):
	var word = $WordList.get_item_text(index)
	$OrderPreview.text += " " + word
	$WordList.unselect_all()
	$SendOrder.disabled = false

func _on_SendOrder_pressed():
	var order = get_current_order()
	send_order(order)
	$SendOrder.disabled = true
	$OrderPreview.text = ""

func _on_ClearOrder_pressed():
	$OrderPreview.text = ""
	$SendOrder.disabled = true

func _on_Patron_clicked(patron):
	if tray.selected_dish != null and patron.state == patron.State.WAITING_TO_ORDER:
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
