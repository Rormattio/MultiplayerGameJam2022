extends Node2D

var received_dish_scene = preload("res://scenes/dining_room/ReceivedDish.tscn")

var DISTANCE_TO_GRAB_DISH = 80

var dishes = []
var dining_room_level
var waiter

func _ready():
	dishes = []

func add_dish(dish : Array):
	var received_dish = received_dish_scene.instance()
	received_dish.build(dish)

	# Move all dishes one place to the right
	for d in dishes:
		d.position.y += 64 + 20

	received_dish.position = Vector2(0, 0)
	received_dish.connect("dish_clicked", self, "_on_Dish_clicked")
	dishes.push_front(received_dish)
	add_child(received_dish)

func remove_dish(dish):
	# Move all remaining dishes one place to the left
	var dish_index = dishes.find(dish)
	assert(dish_index > -1)
	dishes.remove(dish_index)
	remove_child(dish)

	for i in range(dish_index, dishes.size()):
		dishes[i].position.y -= 64 + 20

func _on_Dish_clicked(received_dish):
	if (dining_room_level.carrying_dish_node.get_child(0) == null) and (waiter.position.distance_to(received_dish.global_position) < DISTANCE_TO_GRAB_DISH):
		remove_dish(received_dish)
		dining_room_level.set_carrying_received_dish(received_dish)
	
func _on_Button_pressed():
	add_dish([Global.rand_array(Global.ingredient_names)])
