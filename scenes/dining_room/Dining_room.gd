extends Node

var waiter_scene = preload("res://scenes/dining_room/Waiter.tscn")

var waiter

func _ready():
	Global.connect("cheffe_dish_sent", self, "_on_CheffeDish_Sent")

	$SendOrder.connect("pressed", self, "_on_SendOrder_pressed")
	$SendOrder.disabled = true

	$WordList.connect("multi_selected", self, "_on_WordList_multi_selected")

	waiter = waiter_scene.instance()
	add_child(waiter)

	var words = [
		"scrumptuous",
		"violet",
		"sauce",
		"blue",
		"oblong",
		"fruit",
		"skewer",
		"fancy",
		"dynamic",
		"greenery"
	]

	words.shuffle()

	for w in words:
		$WordList.add_item(w)

func _process(delta):
	pass

func _on_CheffeDish_Sent(dish):
	print("cheffe dish ", dish)

func get_current_order():
	var order_words = []
	for it in $WordList.get_selected_items():
		order_words.append($WordList.get_item_text(it))

	return order_words

func send_order(order):
	Global.waiter_send_command(order)

func _on_WordList_multi_selected(index: int, selected: bool):
	$SendOrder.disabled = get_current_order().size() == 0

func _on_SendOrder_pressed():
	var order = get_current_order()
	send_order(order)
	$WordList.unselect_all()
	$SendOrder.disabled = true
