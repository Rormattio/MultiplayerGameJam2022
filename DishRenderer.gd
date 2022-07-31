extends Object

const Dish = preload("Dish.gd")

static func _load_food_texture(ingredient):
	assert(ingredient != "")
	var result = load("res://assets/food/" + ingredient + ".png")
	assert(result != null)
	return result

static func _add_sprite(root, ingredient, z_index):
	assert(root != null)
	assert(ingredient != "")
	
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
		_add_sprite(root, dish.burger_component_bottom_burger, 1)
		_add_sprite(root, dish.burger_component_mid_burger, 1)
		_add_sprite(root, dish.burger_component_top_burger, 1)
		
		if dish.burger_component_top != "":
			_add_sprite(root, dish.burger_component_top, 1)
	else:
		if dish.non_burger_component_bottom != "":
			_add_sprite(root, dish.non_burger_component_bottom, 1)
		
		if dish.non_burger_component_main != "":
			_add_sprite(root, dish.non_burger_component_main, 1)
		
		if dish.non_burger_component_top != "":
			_add_sprite(root, dish.non_burger_component_top, 1)
	
	if (dish.container_type == Dish.ContainerType.BOWL):
		var dish_front = Sprite.new()
		dish_front.z_index = 2
		dish_front.texture = load("res://assets/food/bowl_front.png")		

		root.add_child(dish_front)

	return root
	
