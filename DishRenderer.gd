extends Object

const Dish = preload("Dish.gd")

static func _load_food_texture(ingredient):
	assert(ingredient != null)
	assert(ingredient != "")
	var desc = Ingredients.get_ingredient_desc(ingredient)
	assert(desc != null)
	assert(desc.png)
	return desc.png

static func _add_sprite_if_needed(root, ingredient, z_index):
	assert(root != null)
	assert(ingredient != null)
	if ingredient != "":
		var top = Sprite.new()
		top.z_index = z_index
		top.texture = _load_food_texture(ingredient)
		root.add_child(top)

static func render_dish(dish : Dish) -> Node2D:
	assert(dish != null)
	var root = Node2D.new()
	
	var dish_back = Sprite.new()
	dish_back.z_index = 0
	if (dish.container_type == Dish.ContainerType.BOWL):
		dish_back.texture = load("res://assets/food/bowl_back.png")
	else:
		assert(dish.container_type == Dish.ContainerType.PLATE)
		dish_back.texture = load("res://assets/food/plate.png")	
	root.add_child(dish_back)
	
	if dish.meal_type == Dish.MealType.BURGER:
		_add_sprite_if_needed(root, dish.burger_component_bottom_burger, 1)
		_add_sprite_if_needed(root, dish.burger_component_mid_burger, 1)
		_add_sprite_if_needed(root, dish.burger_component_top_burger, 1)
		_add_sprite_if_needed(root, dish.burger_component_top, 1)
	elif dish.meal_type == Dish.MealType.SOUP:
		_add_sprite_if_needed(root, dish.soup_component_base, 1)
		_add_sprite_if_needed(root, dish.soup_component_top, 1)
	else:
		assert(dish.meal_type == Dish.MealType.NON_BURGER)
		_add_sprite_if_needed(root, dish.non_burger_component_bottom, 1)
		_add_sprite_if_needed(root, dish.non_burger_component_main, 1)
		_add_sprite_if_needed(root, dish.non_burger_component_top, 1)
	
	if (dish.container_type == Dish.ContainerType.BOWL):
		var dish_front = Sprite.new()
		dish_front.z_index = 2
		dish_front.texture = load("res://assets/food/bowl_front.png")		

		root.add_child(dish_front)

	return root
	
static func render_ingredients(dish : Dish, spacing : int) -> Node2D:
	assert(dish != null)
	var root = Node2D.new()
	
	var ingredients = []
	if dish.meal_type == Dish.MealType.BURGER:
		if dish.burger_component_bottom_burger != "":
			ingredients.append(dish.burger_component_bottom_burger)
		if dish.burger_component_mid_burger != "":
			ingredients.append(dish.burger_component_mid_burger)
		if dish.burger_component_top_burger != "":
			ingredients.append(dish.burger_component_top_burger)
		if dish.burger_component_top != "":
			ingredients.append(dish.burger_component_top)
	elif dish.meal_type == Dish.MealType.SOUP:
		if dish.soup_component_base != "":
			ingredients.append(dish.soup_component_base)
		if dish.soup_component_top != "":
			ingredients.append(dish.soup_component_top)
	else:
		if dish.non_burger_component_bottom != "":
			ingredients.append(dish.non_burger_component_bottom)
		if dish.non_burger_component_main != "":
			ingredients.append(dish.non_burger_component_main)
		if dish.non_burger_component_top != "":
			ingredients.append(dish.non_burger_component_top)
	
	assert(not ingredients.empty())
	
	var current_pos = Vector2(0, 0)
	for ingredient in ingredients:
		var desc = Ingredients.get_ingredient_desc(ingredient)
		var sprite = Sprite.new()
		sprite.z_index = 1
		sprite.texture = _load_food_texture(ingredient)
		sprite.position = current_pos
		current_pos.x += spacing
		root.add_child(sprite)

	return root
