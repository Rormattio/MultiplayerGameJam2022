extends Line2D

const DishRenderer = preload("res://DishRenderer.gd")

onready var waiter_hands = $WaiterHands

const MAX_DISH_ON_COUNTER = 5
var counter_dishes
var node_pos

var removing_dish_idx

func _ready():
	waiter_hands.visible = false
	counter_dishes = []
	for i in range(MAX_DISH_ON_COUNTER):
		counter_dishes.append(null)

	Global.connect("waiter_dish_taken", self, "_on_waiter_dish_taken")

func add_dish_wherever_if_possible(dish):
	for i in range(counter_dishes.size()):
		if counter_dishes[i] == null:
			add_dish_at(dish, i)
			return i

	return -1

func add_dish_at(dish, idx: int):
	assert(idx < MAX_DISH_ON_COUNTER)

	var dish_node = DishRenderer.render_dish(dish)
	node_pos = lerp(self.points[0], self.points[1],
		(idx as float) / (MAX_DISH_ON_COUNTER - 1))

	counter_dishes[idx] = dish_node

	# var button = Button.new()
	# button.rect_position = Vector2(-32, -32)
	# button.rect_size = Vector2(64, 64)
	# button.modulate = Color(1,1,1,0)
	# button.connect("pressed", self, "_on_Dish_pressed", [idx])
	# dish_node.add_child(button)

	dish_node.position = node_pos
	dish_node.global_scale = Vector2(2, 2)
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
	return # We decided that we do not want to let Cheffe remove dishes from the Counter
	remove_dish_at(idx)
	Global.cheffe_trashed_dish(idx)

func _on_waiter_dish_taken(dish_index : int):
	removing_dish_idx = dish_index
	waiter_hands.position = node_pos
	waiter_hands.visible = true
	waiter_hands.frame = 0
	waiter_hands.play()

func _on_WaiterHands_animation_finished():
	waiter_hands.stop()
	waiter_hands.visible = false
	remove_dish_at(removing_dish_idx)

func _on_WaiterHands_frame_changed():
	var node = counter_dishes[removing_dish_idx]
	if waiter_hands.frame >= 8:
		node.position.x -= 9*waiter_hands.scale.x
	elif waiter_hands.frame >= 10:
		node.position.x -= 8*waiter_hands.scale.x
