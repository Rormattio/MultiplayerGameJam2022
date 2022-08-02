extends Line2D

const DishRenderer = preload("res://DishRenderer.gd")

const MAX_DISH_ON_COUNTER = 5
var counter_dishes

func _ready():
	counter_dishes = []
	for i in range(MAX_DISH_ON_COUNTER):
		counter_dishes.append(null)
	
	Global.connect("waiter_dish_taken", self, "_on_waiter_dish_taken")

func add_dish_wherever(dish):
	for i in range(counter_dishes.size()):
		if counter_dishes[i] == null:
			add_dish_at(dish, i)
			return i

	assert(false)

func add_dish_at(dish, idx: int):
	assert(idx < MAX_DISH_ON_COUNTER)

	var dish_node = DishRenderer.render_dish(dish)
	var node_pos = lerp(self.points[0], self.points[1],
		(idx as float) / (MAX_DISH_ON_COUNTER - 1))

	counter_dishes[idx] = dish_node

	var button = Button.new()
	button.rect_position = Vector2(-32, -32)
	button.rect_size = Vector2(64, 64)
	button.modulate = Color(1,1,1,0)
	button.connect("pressed", self, "_on_Dish_pressed", [idx])
	dish_node.add_child(button)

	dish_node.position = node_pos
	#dish_node.global_scale = Vector2(1, 1)
	add_child(dish_node)

func remove_dish_at(idx: int):
	assert(idx < MAX_DISH_ON_COUNTER)

	var node = counter_dishes[idx]
	node.queue_free()
	counter_dishes[idx] = null

func get_free_slots_count() -> int:
	var c = 0
	for i in range(counter_dishes.size()):
		if counter_dishes[i] == null:
			c += 1
	return c

func _on_Dish_pressed(idx: int):
	remove_dish_at(idx)
	Global.cheffe_trashed_dish(idx)

func _on_waiter_dish_taken(dish_index : int):
	remove_dish_at(dish_index)
