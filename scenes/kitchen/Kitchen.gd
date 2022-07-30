extends Node

var cheffe_scene = preload("res://scenes/kitchen/Cheffe.tscn")
var ingredient_stock_scene = preload("res://scenes/kitchen/IngredientStock.tscn")

var cheffe

var ingredient_stocks = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("waiter_command_sent", self, "_on_WaiterCommand_Sent")
	cheffe = cheffe_scene.instance()
	add_child(cheffe)
	
	var ingredient_names = [
		"black_forest_hole",
		"blue_banana",
		"ghosts",
		"grumpy_puree",
		"happy_puree",
		"mighty_puree",
		"smirky_puree",
		"springs",
		"worried_puree",
	]
	var start_x = 50
	var x = start_x
	var y = 50
	var dx = 64
	var w = dx*4
	var dy = 64
	for ingredient_name in ingredient_names:
		var ingredient_stock = ingredient_stock_scene.instance()
		add_child(ingredient_stock)
		ingredient_stocks[ingredient_name] = ingredient_stock
		ingredient_stock.position.x = x
		ingredient_stock.position.y = y
		var ingredient_sprite = load("res://assets/food/" + ingredient_name + ".png")
		ingredient_stock.get_node("Sprite").set_texture(ingredient_sprite)
		x += dx
		if x > w:
			x = start_x
			y += dy
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_WaiterCommand_Sent(dish):
	print("waiter command ", dish)
