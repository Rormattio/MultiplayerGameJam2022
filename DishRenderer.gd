extends Object

const Dish = preload("Dish.gd")

static func _load_food_texture(ingredient):
	assert(ingredient != "")
	var result = load("res://assets/food/" + ingredient + ".png")
	assert(result != null)
	return result
	
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
		var bottom_burger = Sprite.new()
		bottom_burger.z_index = 1
		bottom_burger.texture = _load_food_texture(dish.burger_component_bottom_burger)
		root.add_child(bottom_burger)
		
		var mid_burger = Sprite.new()
		mid_burger.z_index = 1
		mid_burger.texture = _load_food_texture(dish.burger_component_mid_burger)
		root.add_child(mid_burger)

		var top_burger = Sprite.new()
		top_burger.z_index = 1
		top_burger.texture = _load_food_texture(dish.burger_component_top_burger)
		root.add_child(top_burger)

		if dish.burger_component_top != "":
			var top = Sprite.new()
			top.z_index = 1
			top.texture = _load_food_texture(dish.burger_component_top)
			root.add_child(top)
	else:
		if dish.non_burger_component_bottom != "":
			var bottom = Sprite.new()
			bottom.z_index = 1
			bottom.texture = _load_food_texture(dish.non_burger_component_bottom)
			root.add_child(bottom)
		
		if dish.non_burger_component_main != "":
			var main = Sprite.new()
			main.z_index = 1
			main.texture = _load_food_texture(dish.non_burger_component_main)
			root.add_child(main)
		
		if dish.non_burger_component_top != "":
			var top = Sprite.new()
			top.z_index = 1
			top.texture = _load_food_texture(dish.non_burger_component_top)
			root.add_child(top)
	
	if (dish.container_type == Dish.ContainerType.BOWL):
		var dish_front = Sprite.new()
		dish_front.z_index = 2
		dish_front.texture = load("res://assets/food/bowl_front.png")		

		root.add_child(dish_front)

	return root
	
