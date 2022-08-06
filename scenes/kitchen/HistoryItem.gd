extends Node2D

class_name HistoryItem

const Y_DELTA = 160

const DishRenderer = preload("res://DishRenderer.gd")

static func instance_history_item_scene(order : Order, dish_serialized : Array, hints : Array, score : int):
	var history_item_scene = load("res://scenes/kitchen/HistoryItem.tscn")
	var history_item = history_item_scene.instance()

	var command_node = Command.instance_command_scene(Command.Type.HISTORY_COMMAND, order)
	history_item.get_node("CommandPos").add_child(command_node)
	
	var dish = Dish.new()
	dish.deserialize(dish_serialized)
	var dish_node = DishRenderer.render_dish(dish)
	history_item.get_node("DishPos").add_child(dish_node)
	
	history_item.get_node("DishScore").render(hints, score)

	return history_item

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
