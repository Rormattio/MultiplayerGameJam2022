extends Node

var waiter_scene = preload("res://scenes/dining_room/Waiter.tscn")

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

	var words = [
		"scrumptuous",
		"violet",
		"red",
		"yellow",
		"white",
		"sauce",
		"blue",
		"oblong",
		"fruit",
		"skewer",
		"fancy",
		"dynamic",
		"greenery",
		"worried",
		"almighty",
		"smirky",
		"grumpy",
		"happy",
		"puree",
	]

	words.shuffle()

	for w in words:
		$WordList.add_item(w)

func _process(_delta):
	pass

func _on_CheffeDish_Sent(dish):
	print("cheffe dish ", dish)

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
