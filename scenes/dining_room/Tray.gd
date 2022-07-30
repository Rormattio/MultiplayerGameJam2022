extends Node2D

var received_dish_scene = preload("res://scenes/dining_room/ReceivedDish.tscn")

var dishes
var selected_dish

func _ready():
	dishes = []
	selected_dish = null

	pass

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

	# var dish_index = dishes.find(dish)
	# for d in range(dish_index, dishes.size()):


func _on_Button_pressed():
	add_dish([Global.rand_array(Global.ingredient_names)])
