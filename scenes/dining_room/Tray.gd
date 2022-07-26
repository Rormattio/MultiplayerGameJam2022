extends Node2D

const ReceivedDish = preload("ReceivedDish.gd")
const Order = preload("res://scenes/shared/Order.gd")

var received_dish_scene = preload("res://scenes/dining_room/ReceivedDish.tscn")

var DISTANCE_TO_GRAB_DISH
var DISHES_DY = 65

var dishes = []
var dining_room_level
var waiter

func _ready():
	Global.connect("cheffe_dish_sent", self, "_on_CheffeDish_Sent")
	Global.connect("cheffe_dish_trashed", self, "_on_CheffeDish_Trashed")
	
	if Global.DEBUG:
		DISTANCE_TO_GRAB_DISH = 2000
	else:
		DISTANCE_TO_GRAB_DISH = 80

	dishes = []

func add_dish(dish : Array, dish_index: int, order_serialized):
	var received_dish = received_dish_scene.instance()
	received_dish.build(dish)
	received_dish.dish_index_in_kitchen_counter = dish_index
	var order = Order.new()
	order.unserialize(order_serialized)
	received_dish.order = order

	# Move all dishes one place to the right
	for d in dishes:
		d.position.y += DISHES_DY

	received_dish.position = Vector2(0, 0)
	received_dish.connect("dish_clicked", self, "_on_Dish_clicked")
	dishes.push_front(received_dish)
	add_child(received_dish)

func remove_dish(dish : ReceivedDish):
	var dish_index = dishes.find(dish)
	assert(dish_index > -1)
	dish = dishes[dish_index]
	dishes.remove(dish_index)
	remove_child(dish)
	
	# Move all remaining dishes one place up
	for i in range(dish_index, dishes.size()):
		dishes[i].position.y -= DISHES_DY

func _on_CheffeDish_Sent(dish, dish_index, order_serialized):
	Global.logger("cheffe sends dish " + str(dish) + " for command " + str(order_serialized))
	add_dish(dish, dish_index, order_serialized)

func _on_CheffeDish_Trashed(dish_index_in_kitchen_counter):
	for dish in dishes:
		if (dish != null) and (dish.dish_index_in_kitchen_counter == dish_index_in_kitchen_counter):
			remove_dish(dish)
			return
	assert(false)

func _on_Dish_clicked(received_dish):
	if (dining_room_level.carrying_dish_node.get_child(0) == null) and (waiter.position.distance_to(received_dish.global_position) < DISTANCE_TO_GRAB_DISH):
		remove_dish(received_dish)
		dining_room_level.set_carrying_received_dish(received_dish)
		Global.waiter_takes_dish(received_dish.dish_index_in_kitchen_counter)

#func _on_Button_pressed():
#	add_dish([Global.rand_array(Ingredients.ingredient_names)])
