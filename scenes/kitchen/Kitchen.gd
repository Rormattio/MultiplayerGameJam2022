extends Node2D

var cheffe_scene = preload("res://scenes/kitchen/Cheffe.tscn")
var ingredient_stock_scene = preload("res://scenes/kitchen/IngredientStock.tscn")
var command_scene = preload("res://scenes/kitchen/Command.tscn")
var Dish = preload("res://Dish.gd")

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
var max_ingredients = 4

var dish_ingredients
var dish_ingredients_n = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	send_dish.connect("pressed", self, "_on_ButtonPressed")
	Global.connect("waiter_command_sent", self, "_on_WaiterCommand_Sent")
	Global.connect("patron_dish_score_sent", self, "_on_PatronDishScore_Sent")
	
	if not Global.DEBUG:
		$Randomize.queue_free()

	dish_ingredients = []
	for idx in range(max_ingredients):
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
	dish_container.scale.x = 3
	dish_container.scale.y = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_WaiterCommand_Sent(order: Order):
	print("waiter command ", order)
	var words = order.text.split(" ")
	var command = command_scene.instance()
	command.order = order
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
	AudioSfx.play(Global.Sfx.CLICK)
	var dish = []
	for ingredient_name in dish_ingredients:
		if ingredient_name != null:
			dish.append(ingredient_name)
	Global.cheffe_send_dish(dish)

func _on_ingredient_dish_set(ingredient_name):
	assert(ingredient_name != "")
	var idx = dish_ingredients.find(null)
	if (idx == -1 or ingredient_name in dish_ingredients): # all_ingredients are already used
		return false
	var image = ingredient_sprites[ingredient_name]
	var sprite = Sprite.new()
	sprite.set_texture(image)
	sprite.name = ingredient_name # give it a name s that we can easily find it and delete it later
	assert(not dish_container.has_node(ingredient_name))
	dish_container.add_child(sprite)
	assert(dish_container.has_node(ingredient_name))
	dish_ingredients[idx] = ingredient_name
	dish_ingredients_n += 1

	if Global.ingredient_names_to_sfx.has(ingredient_name):
		AudioSfx.play(Global.ingredient_names_to_sfx[ingredient_name])
	return true

func remove_ingredient(ingredient_name):
	var node = dish_container.get_node(ingredient_name);
	assert(node != null)
	dish_container.remove_child(node)
	var idx = dish_ingredients.find(ingredient_name)
	assert(idx > -1)
	dish_ingredients[idx] = null
	dish_ingredients_n -= 1

func _set_plate():
		dish_back.texture = load("res://assets/food/plate.png")
		dish_front.hide()
		current_dish = "plate"
		change_dish.icon = load("res://assets/food/bowl.png")

func _set_bowl():
		dish_back.texture = load("res://assets/food/bowl_back.png")
		dish_front.show()
		current_dish = "bowl"
		change_dish.icon = load("res://assets/food/plate.png")

func _on_ChangeDish_pressed():
	AudioSfx.play(Global.Sfx.CLICK)
	if (current_dish == "plate"):
		_set_bowl()
	else:
		assert(current_dish == "bowl")
		_set_plate()

func _clear_dish():
	print("Clearing : ", dish_ingredients)
	for ingredient_name in dish_ingredients:
		if ingredient_name != null:
			remove_ingredient(ingredient_name)

func _on_Trash_pressed():
	AudioSfx.play(Global.Sfx.CLICK)
	_clear_dish()

func _set_dish(new_dish):
	_clear_dish()

	if new_dish.container_type == Dish.ContainerType.BOWL:
		_set_bowl()
	else:
		assert(new_dish.container_type == Dish.ContainerType.PLATE)
		_set_plate()

	# TODO : For now we marshall Dish to what's used there but we should share the representation
	if (new_dish.meal_type == Dish.MealType.BURGER):
		_on_ingredient_dish_set(new_dish.burger_component_bottom_burger)
		_on_ingredient_dish_set(new_dish.burger_component_mid_burger)
		_on_ingredient_dish_set(new_dish.burger_component_top_burger)
		if new_dish.burger_component_top != "":
			_on_ingredient_dish_set(new_dish.burger_component_top)
	else:
		assert(new_dish.meal_type == Dish.MealType.NON_BURGER)
		if new_dish.non_burger_component_bottom != "":
			_on_ingredient_dish_set(new_dish.non_burger_component_bottom)
		if new_dish.non_burger_component_main != "":
			_on_ingredient_dish_set(new_dish.non_burger_component_main)
		if new_dish.non_burger_component_top != "":
			_on_ingredient_dish_set(new_dish.non_burger_component_top)

func _on_Randomize_pressed():

	var new_dish = Dish.new()
	new_dish.randomize()
	new_dish.debug_print()

	_set_dish(new_dish)


func _on_PatronDishScore_Sent(dish, score):
	# TODO: actually show the dish
	print("dish score ", dish, score)
