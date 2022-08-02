extends Node2D

var cheffe_scene = preload("res://scenes/kitchen/Cheffe.tscn")
var ingredient_stock_scene = preload("res://scenes/kitchen/IngredientStock.tscn")
var command_scene = preload("res://scenes/kitchen/Command.tscn")
const Dish = preload("res://Dish.gd")
const DishRenderer = preload("res://DishRenderer.gd")

onready var send_dish = $SendDish
onready var change_dish = $ChangeDish

onready var dish_back = $Dish/DishBack # z index 0
onready var dish_container = $Dish/DishContainer # z index 1
onready var dish_front = $Dish/DishFront # z index 2

onready var current_container_type = Dish.ContainerType.PLATE

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
	send_dish.connect("pressed", self, "_on_SendDish_Pressed")
	Global.connect("waiter_command_sent", self, "_on_WaiterCommand_Sent")
	Global.connect("patron_dish_score_sent", self, "_on_PatronDishScore_Sent")

	if not Global.DEBUG:
		$Randomize.queue_free()

	dish_ingredients = []
	for idx in range(max_ingredients):
		dish_ingredients.append("")

	# TODO: add hands maybe?
	# CHEFFE
	# cheffe = cheffe_scene.instance()
	# add_child(cheffe)

	# DISH
	dish_front.hide()
	for asset in [dish_back, dish_front]:
		asset.scale.x = 3
		asset.scale.y = 3
	dish_container.scale.x = 3
	dish_container.scale.y = 3

	for ingredient_name in Global.ingredient_names:
		var ingredient_stock = ingredient_stock_scene.instance()
		ingredient_stock.connect("ingredient_dish_set", self, "_on_ingredient_dish_set")
		ingredient_stocks[ingredient_name] = ingredient_stock
		ingredient_stock.ingredient_name = ingredient_name
		var ingredient_sprite = load("res://assets/food/" + ingredient_name + ".png")
		ingredient_sprites[ingredient_name] = ingredient_sprite
		ingredient_stock.get_node("Sprite").set_texture(ingredient_sprite)

	_refresh_stock()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _is_possible_next_ingredient_0(ingredient_desc):
	assert(ingredient_desc != null);

	if current_container_type == Dish.ContainerType.BOWL:
		if ingredient_desc.has_tag("bottom_burger"):
			return false
		if ingredient_desc.has_tag("bottom"):
			return false

	return not ingredient_desc.has_any_tag(["mid_burger", "top_burger", "flag"])

func _is_possible_next_ingredient_1(ingredient_desc):
	assert(ingredient_desc != null);

	var is_burger = (dish_ingredients[0] != "") and Global.is_bottom_burger_ingredient(dish_ingredients[0])
	if is_burger:
		return ingredient_desc.has_tag("mid_burger")
	else:
		return not ingredient_desc.has_any_tag(["bottom_burger", "mid_burger", "top_burger", "flag"])

func _is_possible_next_ingredient_2(ingredient_desc):
	assert(ingredient_desc != null);

	var is_burger = (dish_ingredients[0] != "") and Global.is_bottom_burger_ingredient(dish_ingredients[0])
	if is_burger:
		return (ingredient_desc != null) and ingredient_desc.has_tag("top_burger")
	else:
		return ingredient_desc.has_tag("top") and not ingredient_desc.has_tag("flag")

func _is_possible_next_ingredient_3(ingredient_desc):
	assert(ingredient_desc != null);

	var is_burger = (dish_ingredients[0] != "") and Global.is_bottom_burger_ingredient(dish_ingredients[0])
	if is_burger:
		return ingredient_desc.has_tag("top")
	else:
		return false

# This should help the player to create a valid Dish
func _is_possible_next_ingredient(ingredient_desc):
	assert(ingredient_desc != null);

	match dish_ingredients_n:
		0:
			return _is_possible_next_ingredient_0(ingredient_desc)
		1:
			return _is_possible_next_ingredient_1(ingredient_desc)
		2:
			return _is_possible_next_ingredient_2(ingredient_desc)
		3:
			return _is_possible_next_ingredient_3(ingredient_desc)
		4:
			return false
		_:
			assert(false)
			return false

func _refresh_stock():
	while $IngredientStockContainer.get_child_count() > 0:
		var node = $IngredientStockContainer.get_child(0)
		$IngredientStockContainer.remove_child(node)

	var start_x = 900
	var x = start_x
	var y = 50
	var dx = 64
	var w = dx*4
	var dy = 64
	for ingredient_desc in Global.ingredient_descs:
		var ingredient_name = ingredient_desc.name
		var ingredient_stock = ingredient_stocks[ingredient_name]
		ingredient_stock.set_enabled(_is_possible_next_ingredient(ingredient_desc))
		ingredient_stock.position.x = x
		ingredient_stock.position.y = y
		$IngredientStockContainer.add_child(ingredient_stock)
		x += dx
		if x > w + start_x:
			x = start_x
			y += dy

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

func _on_SendDish_Pressed():
	AudioSfx.play(Global.Sfx.CLICK)

	var container_type
	if current_container_type == Dish.ContainerType.PLATE:
		container_type = Dish.ContainerType.PLATE;
	else:
		assert(current_container_type == Dish.ContainerType.BOWL)
		container_type = Dish.ContainerType.BOWL;
	var induced_dish = Dish.new()
	var can_make_a_dish = induced_dish.make_from_linear_ingredients(container_type, dish_ingredients)
	assert(can_make_a_dish)
	assert(induced_dish.is_valid())

	var dish_idx = $Counter.add_dish_wherever(induced_dish)
	if $Counter.get_free_slots_count() == 0:
		$SendDish.disabled = true

	_clear_dish()
	_refresh_stock()

	var serialized_dish = induced_dish.serialize()
	Global.cheffe_send_dish(serialized_dish, dish_idx)

func _on_ingredient_dish_set(ingredient_name):
	var idx = dish_ingredients_n
	if ingredient_name != "":

		# dish_ingredients is linear and contains holes to be able to map to a future Dish so we
		# need to pad it with "" to manage optional components (see Dish grammar)
		var padding_needed
		match dish_ingredients_n:
			0:
				if Global.is_main_ingredient(ingredient_name):
					padding_needed = 1
				elif Global.is_top_ingredient(ingredient_name):
					padding_needed = 2
				else:
					padding_needed = 0
			1:
				var is_burger = dish_ingredients[0] != "" and Global.is_bottom_burger_ingredient(dish_ingredients[0])
				if is_burger:
					padding_needed = 0
				else:
					if Global.is_top_ingredient(ingredient_name):
						padding_needed = 1
					else:
						padding_needed = 0
			2:
				padding_needed = 0
			3:
				padding_needed = 0
			_:
				assert(false)
		for i in range(padding_needed):
			dish_ingredients[idx] = ""
			idx += 1
			dish_ingredients_n += 1

		var image = ingredient_sprites[ingredient_name]
		var sprite = Sprite.new()
		sprite.set_texture(image)
		sprite.name = ingredient_name # give it a name s that we can easily find it and delete it later
		assert(not dish_container.has_node(ingredient_name))
		dish_container.add_child(sprite)
		assert(dish_container.has_node(ingredient_name))
	dish_ingredients[idx] = ingredient_name
	idx += 1
	dish_ingredients_n += 1

	if Global.ingredient_names_to_sfx.has(ingredient_name):
		AudioSfx.play(Global.ingredient_names_to_sfx[ingredient_name])

	_refresh_stock()
	return true

func _set_plate():
		dish_back.texture = load("res://assets/food/plate.png")
		dish_front.hide()
		current_container_type = Dish.ContainerType.PLATE
		change_dish.icon = load("res://assets/food/bowl.png")

func _set_bowl():
		dish_back.texture = load("res://assets/food/bowl_back.png")
		dish_front.show()
		current_container_type = Dish.ContainerType.BOWL
		change_dish.icon = load("res://assets/food/plate.png")

func _on_ChangeDish_pressed():
	AudioSfx.play(Global.Sfx.CLICK)
	if (current_container_type == Dish.ContainerType.PLATE):
		_set_bowl()
	else:
		assert(current_container_type == Dish.ContainerType.BOWL)
		_set_plate()
	_refresh_stock()

func _clear_dish():
	print("Clearing : ", dish_ingredients)

	for idx in range(dish_ingredients_n):
		if 	dish_ingredients[idx] != "":
			var node = dish_container.get_node(dish_ingredients[idx])
			assert(node != null)
			dish_container.remove_child(node)
			node.queue_free()

	dish_ingredients = []
	for idx in range(max_ingredients):
		dish_ingredients.append("")
	dish_ingredients_n = 0

func _on_Trash_pressed():
	AudioSfx.play(Global.Sfx.CLICK)
	_clear_dish()
	_refresh_stock()

func _set_dish(new_dish : Dish):
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
		_on_ingredient_dish_set(new_dish.burger_component_top)
	else:
		assert(new_dish.meal_type == Dish.MealType.NON_BURGER)
		_on_ingredient_dish_set(new_dish.non_burger_component_bottom)
		_on_ingredient_dish_set(new_dish.non_burger_component_main)
		_on_ingredient_dish_set(new_dish.non_burger_component_top)

func _on_Randomize_pressed():

	var new_dish = Dish.new()
	new_dish.randomize()
	new_dish.debug_print()

	# Debug code for the DishRenderer
	if false:
		var new_dish_sprite = DishRenderer.render_dish(new_dish)
		new_dish_sprite.position = Vector2(0, 200)
		new_dish_sprite.global_scale = Vector2(3, 3)
		add_child(new_dish_sprite)

	_set_dish(new_dish)
	_refresh_stock()


func _on_PatronDishScore_Sent(dish, score):
	# TODO: actually show the dish
	print("dish score ", dish, score)
