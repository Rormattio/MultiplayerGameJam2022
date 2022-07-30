extends Node

var cheffe_scene = preload("res://scenes/kitchen/Cheffe.tscn")
var ingredient_stock_scene = preload("res://scenes/kitchen/IngredientStock.tscn")
var command_scene = preload("res://scenes/kitchen/Command.tscn")

onready var send_dish = $SendDish
onready var change_dish = $ChangeDish

onready var dish_back = $Dish/DishBack # z index 0
onready var dish_container = $Dish/DishContainer # z index 1
onready var dish_front = $Dish/DishFront # z index 2

onready var current_dish = "plate"

onready var commands_container = $CommandsContainer

var cheffe

var active_commands = []
var command_counter = 0

var ingredient_sprites = {}
var ingredient_stocks = {}
var dish_ingredient_offsets = [
	[0,20],
	[-30,-10],
	[30,-10],
]
var dish_ingredients
var dish_ingredients_n = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	send_dish.connect("pressed", self, "_on_ButtonPressed")
	Global.connect("waiter_command_sent", self, "_on_WaiterCommand_Sent")
	
	dish_ingredients = []
	for idx in range(len(dish_ingredient_offsets)):
		dish_ingredients.append(null)
	
	# CHEFFE
	cheffe = cheffe_scene.instance()
	add_child(cheffe)
	
	# STOCK
	var start_x = 900
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
		if x > w + start_x:
			x = start_x
			y += dy
	
	# DISH
	dish_front.hide()
	for asset in [dish_back, dish_front]:
		asset.scale.x = 3
		asset.scale.y = 3
	dish_container.scale.x = 2
	dish_container.scale.y = 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_WaiterCommand_Sent(dish):
	print("waiter command ", dish)
	var words = dish.split(" ")
	var command = command_scene.instance()
	commands_container.add_child(command)
	command.connect("close_command", self, "_on_close_command")
	command.name = str(command_counter)
	var word_items = command.get_node("Words")
	for word in words:
		word_items.add_item(word)
	command.position.x = (word_items.rect_size.x + 10)*len(active_commands)
	active_commands.append(command)
	command_counter += 1

func _on_close_command(name):
	print("delete command " + name)
	var command = commands_container.get_node(name)
	var command_idx = active_commands.find(command)
	assert(command_idx > -1)
	var prev_command = command
	var curr_command
	for idx in range(command_idx+1, len(active_commands)):
		curr_command = active_commands[idx]
		curr_command.position.x -= prev_command.get_node("Words").rect_size.x + 10
		prev_command = curr_command
	active_commands.remove(command_idx)
	command.queue_free() # find and delete by name

func _on_ButtonPressed():
	var dish = ""
	for ingredient_name in dish_ingredients:
		if len(dish) > 0:
			dish += " "
		dish += ingredient_name
	Global.cheffe_send_dish(dish)

func _on_ingredient_dish_set(toggled, ingredient_name):
	if toggled:
		var idx = dish_ingredients.find(null)
		assert(idx > -1)
		var image = ingredient_sprites[ingredient_name]
		var sprite = Sprite.new()
		sprite.set_texture(image)
		sprite.name = ingredient_name # give it a name s that we can easily find it and delete it later
		dish_container.add_child(sprite)
		sprite.position.x = dish_ingredient_offsets[idx][0]
		sprite.position.y = dish_ingredient_offsets[idx][1]
		dish_ingredients[idx] = ingredient_name
		dish_ingredients_n += 1
		if dish_ingredients_n == len(dish_ingredient_offsets):
			for ingredient_name in ingredient_stocks:
				if not (ingredient_name in dish_ingredients):
					var ingredient_stock = ingredient_stocks[ingredient_name]
					ingredient_stock.get_node("CheckBox").disabled = true
	else:
		dish_container.get_node(ingredient_name).queue_free() # find and delete by name
		var idx = dish_ingredients.find(ingredient_name)
		assert(idx > -1)
		dish_ingredients[idx] = null
		dish_ingredients_n -= 1
		if dish_ingredients_n == len(dish_ingredient_offsets) - 1:
			for ingredient_name in ingredient_stocks:
				var ingredient_stock = ingredient_stocks[ingredient_name]
				ingredient_stock.get_node("CheckBox").disabled = false
		

func _on_ChangeDish_pressed():
	if (current_dish == "plate"):
		dish_back.texture = load("res://assets/food/bowl_back.png")
		dish_front.show()
		current_dish = "bowl"
		change_dish.icon = load("res://assets/food/plate.png")
	else:
		dish_back.texture = load("res://assets/food/plate.png")
		dish_front.hide()
		current_dish = "plate"
		change_dish.icon = load("res://assets/food/bowl.png")
	pass # Replace with function body.
