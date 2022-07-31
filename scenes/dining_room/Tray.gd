extends Node2D

var received_dish_scene = preload("res://scenes/dining_room/ReceivedDish.tscn")

var dishes = []
var selected_dish = null

func _ready():
	dishes = []
	selected_dish = null

func add_dish(dish):
	var received_dish = received_dish_scene.instance()
	for ingredient_name in dish:
		received_dish.add_ingredient(ingredient_name)

	# Move all dishes one place to the right
	for d in dishes:
		d.position.x += 64 + 20

	received_dish.position = self.position
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
		dishes[i].position.x -= 64 + 20

	if selected_dish == dish:
		dish.set_selected(false)
		selected_dish = null

func _on_Dish_clicked(dish):
	if selected_dish == null:
		selected_dish = dish
		dish.set_selected(true)

	elif selected_dish == dish:
		selected_dish.set_selected(false)
		selected_dish = null

	else:
		selected_dish.set_selected(false)
		selected_dish = dish
		dish.set_selected(true)

func _on_Button_pressed():
	add_dish([Global.rand_array(Global.ingredient_names)])
