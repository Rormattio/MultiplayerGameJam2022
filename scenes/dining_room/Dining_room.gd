extends Node

var waiter_scene = preload("res://scenes/dining_room/Waiter.tscn")

var waiter

func _ready():
	Global.connect("cheffe_dish_sent", self, "_on_CheffeDish_Sent")

	$SendOrder.connect("pressed", self, "_on_SendOrder_pressed")
	$SendOrder.disabled = true

	$WordList.connect("multi_selected", self, "_on_WordList_multi_selected")
	$OrderPreview.text = ""

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

func get_current_order() -> Array:
	var order_words = []
	for it in $WordList.get_selected_items():
		order_words.append($WordList.get_item_text(it))

	return order_words

func build_order_string(order_words) -> String:
	var order = ""
	for w in order_words:
		order += w + " "
	return order

func send_order(order):
	print("sent order ", order)
	Global.waiter_send_command(order)

func _on_WordList_multi_selected(index: int, selected: bool):
	var current_order = get_current_order()
	$OrderPreview.text = build_order_string(current_order)
	$SendOrder.disabled = current_order.size() == 0

func _on_SendOrder_pressed():
	var order = get_current_order()
	send_order(order)
	$WordList.unselect_all()
	$SendOrder.disabled = true
	$OrderPreview.text = ""
