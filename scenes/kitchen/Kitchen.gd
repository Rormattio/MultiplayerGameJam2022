extends Node

var cheffe_scene = preload("res://scenes/kitchen/Cheffe.tscn")
var ingredient_stock_scene = preload("res://scenes/kitchen/IngredientStock.tscn")

onready var send_dish = $SendDish
onready var bowl_back = $BowlBack # z index 0
onready var bowl_front = $BowlFront # z index 2
onready var bowl_container = $BowlContainer # z index 1

var cheffe

var ingredient_sprites = {}
var ingredient_stocks = {}
var dish_ingredients = []
var dish_ingredient_offsets = [
	[0,20],
	[-30,-10],
	[30,-10],
]

# Called when the node enters the scene tree for the first time.
func _ready():
	send_dish.connect("pressed", self, "_on_ButtonPressed")
	Global.connect("waiter_command_sent", self, "_on_WaiterCommand_Sent")
	
	# CHEFFE
	cheffe = cheffe_scene.instance()
	add_child(cheffe)
	
	# STOCK
	var start_x = 50
	var x = start_x
	var y = 50
	var dx = 64
	var w = dx*4
	var dy = 64
	for ingredient_name in Global.ingredient_names:
		var ingredient_stock = ingredient_stock_scene.instance()
		add_child(ingredient_stock)
		ingredient_stock.connect("ingredient_dish_set", self, "_on_ingredient_dish_set")
		ingredient_stocks[ingredient_name] = ingredient_stock
		ingredient_stock.ingredient_name = ingredient_name
		ingredient_stock.position.x = x
		ingredient_stock.position.y = y
		var ingredient_sprite = load("res://assets/food/" + ingredient_name + ".png")
		ingredient_sprites[ingredient_name] = ingredient_sprite
		ingredient_stock.get_node("Sprite").set_texture(ingredient_sprite)
		x += dx
		if x > w:
			x = start_x
			y += dy
	
	# DISH
	for asset in [bowl_back, bowl_front]:
		asset.position.x = 600
		asset.position.y = 400
		asset.scale.x = 3
		asset.scale.y = 3
	bowl_container.position.x = 600
	bowl_container.position.y = 400
	bowl_container.scale.x = 2
	bowl_container.scale.y = 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_WaiterCommand_Sent(dish):
	print("waiter command ", dish)

func _on_ButtonPressed():
	var dish = ""
	for ingredient_name in dish_ingredients:
		if len(dish) > 0:
			dish += " "
		dish += ingredient_name
	Global.cheffe_send_dish(dish)

func _on_ingredient_dish_set(toggled, ingredient_name):
	if toggled:
		var idx = len(dish_ingredients)
		var image = ingredient_sprites[ingredient_name]
		var sprite = Sprite.new()
		sprite.set_texture(image)
		sprite.name = ingredient_name # give it a name s that we can easily find it and delete it later
		bowl_container.add_child(sprite)
		sprite.position.x = dish_ingredient_offsets[idx][0]
		sprite.position.y = dish_ingredient_offsets[idx][1]
		dish_ingredients.append(ingredient_name)
		if len(dish_ingredients) == len(dish_ingredient_offsets):
			for ingredient_name in ingredient_stocks:
				if not (ingredient_name in dish_ingredients):
					var ingredient_stock = ingredient_stocks[ingredient_name]
					ingredient_stock.get_node("CheckBox").disabled = true
	else:
		bowl_container.get_node(ingredient_name).queue_free() # find and delete by name
		dish_ingredients.erase(ingredient_name)
		if len(dish_ingredients) == len(dish_ingredient_offsets) - 1:
			for ingredient_name in ingredient_stocks:
				var ingredient_stock = ingredient_stocks[ingredient_name]
				ingredient_stock.get_node("CheckBox").disabled = false
		
		

