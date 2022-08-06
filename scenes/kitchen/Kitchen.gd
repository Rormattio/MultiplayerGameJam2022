extends Node2D

var cheffe_scene = preload("res://scenes/kitchen/Cheffe.tscn")
var ingredient_stock_scene = preload("res://scenes/kitchen/IngredientStock.tscn")
const Dish = preload("res://Dish.gd")
const DishRenderer = preload("res://DishRenderer.gd")

onready var change_dish = $ChangeDish

onready var dish_back = $Dish/DishBack # z index 0
onready var dish_container = $Dish/DishContainer # z index 1
onready var dish_front = $Dish/DishFront # z index 2

onready var current_container_type = Dish.ContainerType.PLATE

onready var commands_container = $CommandsContainer
onready var audio_sfx = $AudioSfx

var cheffe

var active_commands = []
var command_counter = 0

var ingredient_sprites = {}
var ingredient_stocks = {}
var max_ingredients = 4

var dish_ingredients
var dish_ingredients_n = 0

var history_items = []
const HISTORY_ITEMS_MAX_SIZE = 8

enum State {
	COOKING,
	SHOWING_HISTORY,
}
var state = State.COOKING

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("waiter_command_sent", self, "_on_WaiterCommand_Sent")
	Global.connect("patron_dish_score_sent", self, "_on_PatronDishScore_Sent")
	$History.visible = false
	
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

	for ingredient_name in Ingredients.ingredient_names:
		var ingredient_stock = ingredient_stock_scene.instance()
		ingredient_stock.connect("ingredient_dish_set", self, "_on_ingredient_dish_set")
		ingredient_stocks[ingredient_name] = ingredient_stock
		ingredient_stock.ingredient_name = ingredient_name
		var ingredient_sprite = load("res://assets/food/" + ingredient_name + ".png")
		ingredient_sprites[ingredient_name] = ingredient_sprite
		ingredient_stock.get_node("Sprite").set_texture(ingredient_sprite)

	_refresh_stock()
	
	audio_sfx.play_ambience()

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
		return not ingredient_desc.has_any_tag(["soup_top", "mid_burger", "top_burger", "flag"])
	else:
		assert(current_container_type == Dish.ContainerType.PLATE)
		return not ingredient_desc.has_any_tag(["soup_base", "soup_top", "mid_burger", "top_burger", "flag"])

func _is_possible_next_ingredient_1(ingredient_desc):
	assert(ingredient_desc != null);

	var is_burger = (dish_ingredients[0] != "") and Ingredients.is_bottom_burger_ingredient(dish_ingredients[0])
	var is_soup = (dish_ingredients[0] != "") and Ingredients.is_soup_base_ingredient(dish_ingredients[0])
	if is_burger:
		return ingredient_desc.has_tag("mid_burger")
	elif is_soup:
		return ingredient_desc.has_tag("soup_top")
	else:
		return not ingredient_desc.has_any_tag(["soup_base", "soup_top", "bottom", "bottom_burger", "mid_burger", "top_burger", "flag"])

func _is_possible_next_ingredient_2(ingredient_desc):
	assert(ingredient_desc != null);

	var is_burger = (dish_ingredients[0] != "") and Ingredients.is_bottom_burger_ingredient(dish_ingredients[0])
	var is_soup = (dish_ingredients[0] != "") and Ingredients.is_soup_base_ingredient(dish_ingredients[0])
	if is_burger:
		return (ingredient_desc != null) and ingredient_desc.has_tag("top_burger")
	elif is_soup:
		return false
	else:
		return ingredient_desc.has_tag("top") and not ingredient_desc.has_tag("flag")

func _is_possible_next_ingredient_3(ingredient_desc):
	assert(ingredient_desc != null);

	var is_burger = (dish_ingredients[0] != "") and Ingredients.is_bottom_burger_ingredient(dish_ingredients[0])
	var is_soup = (dish_ingredients[0] != "") and Ingredients.is_soup_base_ingredient(dish_ingredients[0])
	assert(not is_soup)
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

const TAG_SORT_ORDER = [ "bottom", "bottom_burger", "soup_base", "main", "mid_burger", "top_burger", "top", "soup_top" ]

class StockIngredientSorter:
	static func sort(a, b):
		var desc_a = Ingredients.get_ingredient_desc(a)
		var desc_b = Ingredients.get_ingredient_desc(b)
		assert(desc_a != null)
		assert(desc_b != null)
		
		var index_a = TAG_SORT_ORDER.find(desc_a.tags[0])
		var index_b = TAG_SORT_ORDER.find(desc_b.tags[0])
		assert(index_a != -1)
		assert(index_b != -1)
		if index_a < index_b:
			return true
		elif index_a > index_b:
			return false
		else:
			return a < b # Alphabetic order

func _refresh_stock():
	while $IngredientStockContainer.get_child_count() > 0:
		var node = $IngredientStockContainer.get_child(0)
		$IngredientStockContainer.remove_child(node)

	var ingredient_names = Ingredients.ingredient_names.duplicate()
	ingredient_names.sort_custom(StockIngredientSorter, "sort")


	var ITEMS_PER_LINE = 6
	var start_x = 900
	var x = start_x
	var y = 50
	var dx = 64
	var w = dx*ITEMS_PER_LINE
	var dy = 64
	for ingredient_name in ingredient_names:
		var ingredient_desc = Ingredients.get_ingredient_desc(ingredient_name)
		assert(ingredient_desc != null)
		var ingredient_stock = ingredient_stocks[ingredient_name]
		ingredient_stock.set_enabled(_is_possible_next_ingredient(ingredient_desc))
		ingredient_stock.position.x = x
		ingredient_stock.position.y = y
		$IngredientStockContainer.add_child(ingredient_stock)
		x += dx
		if x >= w + start_x:
			x = start_x
			y += dy

func _on_WaiterCommand_Sent(order: Order):
	print("waiter command ", order)
	var command = Command.instance_command_scene(Command.Type.ACTIVE_COMMAND, order)
	commands_container.add_child(command)
	command.connect("close_command", self, "_on_close_command")
	command.connect("send_dish_pressed", self, "_on_SendDish_Pressed")
	var word_items = command.get_node("Words")
	command.position.x = (word_items.rect_size.x + 10)*len(active_commands)
	command.name = str(command_counter)
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

func _on_SendDish_Pressed(command):
	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)

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

	var dish_idx = $Counter.add_dish_wherever_if_possible(induced_dish)

	if dish_idx > -1:
		_clear_dish()
		_refresh_stock()

		var serialized_dish = induced_dish.serialize()
		Global.cheffe_send_dish(serialized_dish, dish_idx, command.order.serialize())
		_on_close_command(command.name)

func _on_ingredient_dish_set(ingredient_name):
	var idx = dish_ingredients_n
	if ingredient_name != "":

		# dish_ingredients is linear and contains holes to be able to map to a future Dish so we
		# need to pad it with "" to manage optional components (see Dish grammar)
		var padding_needed
		match dish_ingredients_n:
			0:
				if Ingredients.is_main_ingredient(ingredient_name):
					padding_needed = 1
				elif Ingredients.is_top_ingredient(ingredient_name):
					padding_needed = 2
				else:
					padding_needed = 0
			1:
				var is_burger = dish_ingredients[0] != "" and Ingredients.is_bottom_burger_ingredient(dish_ingredients[0])
				if is_burger:
					padding_needed = 0
				else:
					if Ingredients.is_top_ingredient(ingredient_name):
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

	if ingredient_name != "":
		var sfx = Ingredients.get_ingredient_desc(ingredient_name).sfx
		if sfx != null:
			AudioSfx.play_ingredient(sfx)

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
	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)
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
	AudioSfx.play_ingredient(Ingredients.Sfx.CLICK)
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
	elif (new_dish.meal_type == Dish.MealType.SOUP):
		_on_ingredient_dish_set(new_dish.soup_component_base)
		_on_ingredient_dish_set(new_dish.soup_component_top)
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

func _on_PatronDishScore_Sent(received_dish_serialized, score, order_serialized, hints):
	print("dish=", received_dish_serialized, " score=", score, " order=", order_serialized)
	var ingredients = []
	for idx in range(2, len(received_dish_serialized)):
		ingredients.push_back(received_dish_serialized[idx])
	var order = Order.new()
	order.unserialize(order_serialized)
	var clues = order.text.split(" ")
	
	# create feedbacks on IngredientStock
	for ingredient_name in ingredients:
		if ingredient_name != "":
			ingredient_stocks[ingredient_name].score_feedback(clues, score)
	
	# add to history
	var history_item : HistoryItem = HistoryItem.instance_history_item_scene(order, received_dish_serialized, hints, score)
	$History.add_child(history_item)
	
	if len(history_items) >= HISTORY_ITEMS_MAX_SIZE:
		assert(len(history_items) == HISTORY_ITEMS_MAX_SIZE)
		history_items.pop_front()
		for history_idx in range(len(history_items)):
			var _history_item = history_items[history_idx]
			_history_item.position = position_for_history_item_index(history_idx)

	history_item.position = position_for_history_item_index(len(history_items))
	history_items.append(history_item)

func position_for_history_item_index(history_idx):
	var x
	var y
	var n_items_per_col = HISTORY_ITEMS_MAX_SIZE/2
	if history_idx < n_items_per_col:
		x = $History/ItemsPosColumn0.position.x
	else:
		x = $History/ItemsPosColumn0/ItemsPosColumn1.position.x
	y = $History/ItemsPosColumn0.position.y + HistoryItem.Y_DELTA * (history_idx % n_items_per_col)
	return Vector2(x, y)

func toggle_history():
	match state:
		State.COOKING:
			state = State.SHOWING_HISTORY
			$History.visible = true
		State.SHOWING_HISTORY:
			state = State.COOKING
			$History.visible = false

func _on_ButtonHistory_button_up():
	toggle_history()

func _on_CloseHistory_button_up():
	assert(state == State.SHOWING_HISTORY)
	toggle_history()
