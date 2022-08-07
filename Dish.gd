extends Object

class_name Dish

# dish = (container, meal)
# container = bowl | plate
# meal = burger | non-burger
# non_burger = (bottom | _, main | _, top | _)
# burger = (bottom-burger, mid-burger, top-burger, top | _)

enum ContainerType { BOWL, PLATE }
enum MealType { BURGER, NON_BURGER, SOUP }

var container_type
var meal_type

var burger_component_bottom_burger
var burger_component_mid_burger
var burger_component_top_burger
var burger_component_top

var non_burger_component_bottom
var non_burger_component_main
var non_burger_component_top

var soup_component_base
var soup_component_top

const BURGER_COMPONENT_TOP_PROBABILITY = 0.5
const SOUP_COMPONENT_TOP_PROBABILITY = 0.5
const NON_BURGER_COMPONENT_BOTTOM_PROBABILITY = 0.5
const NON_BURGER_COMPONENT_MAIN_PROBABILITY = 0.8
const NON_BURGER_COMPONENT_TOP_PROBABILITY = 0.5

func get_element_count():
	var result = 0
	if meal_type == MealType.SOUP:
		if soup_component_base != "":
			result += 1
		if soup_component_top != "":
			result += 1
	elif meal_type == MealType.BURGER:
		if burger_component_bottom_burger != "":
			result += 1
		if burger_component_mid_burger != "":
			result += 1
		if burger_component_top_burger != "":
			result += 1
		if burger_component_top != "":
			result += 1
	else:
		assert(meal_type == MealType.NON_BURGER)
		if non_burger_component_bottom != "":
			result += 1
		if non_burger_component_main != "":
			result += 1
		if non_burger_component_top != "":
			result += 1
	return result

func _randomize_dish_container():
	return ContainerType.get(ContainerType.keys()[randi() % ContainerType.size()])

func _randomize_dish_meal_type():
	var meal_type_rnd = randi() % 100
	if meal_type_rnd < 40:
		return MealType.BURGER
	elif meal_type_rnd < 60:
		return MealType.SOUP
	else:
		return MealType.NON_BURGER

func _randomize_burger():
	assert(meal_type == MealType.BURGER)
	burger_component_bottom_burger = Ingredients.bottom_burger_ingredients[randi() % Ingredients.bottom_burger_ingredients.size()]
	burger_component_mid_burger = Ingredients.mid_burger_ingredients[randi() % Ingredients.mid_burger_ingredients.size()]
	burger_component_top_burger = Ingredients.top_burger_ingredients[randi() % Ingredients.top_burger_ingredients.size()]

	if randf() <= BURGER_COMPONENT_TOP_PROBABILITY:
		burger_component_top = Ingredients.top_ingredients[randi() % Ingredients.top_ingredients.size()]
	else:
		burger_component_top = ""
	return

func _randomize_soup():
	assert(meal_type == MealType.SOUP)
	soup_component_base = Ingredients.get_random_ingredient_with_tag("soup_base")
	if randf() <= SOUP_COMPONENT_TOP_PROBABILITY:
		soup_component_top = Ingredients.get_random_ingredient_with_tag("soup_top")
	else:
		soup_component_top = ""
	return

func _randomize_non_burger():
	assert(meal_type == MealType.NON_BURGER)
	if randf() <= NON_BURGER_COMPONENT_BOTTOM_PROBABILITY:
		non_burger_component_bottom = Ingredients.bottom_ingredients[randi() % Ingredients.bottom_ingredients.size()]
	else:
		non_burger_component_bottom = ""

	if randf() <= NON_BURGER_COMPONENT_MAIN_PROBABILITY:
		non_burger_component_main = Ingredients.main_ingredients[randi() % Ingredients.main_ingredients.size()]
	else:
		non_burger_component_main = ""

	if randf() <= NON_BURGER_COMPONENT_TOP_PROBABILITY:
		non_burger_component_top = Ingredients.top_ingredients[randi() % Ingredients.top_ingredients.size()]
	else:
		non_burger_component_top = ""
	return

func is_valid():
	# Here we will prevent impossible combinations if necessary
	if (container_type == ContainerType.BOWL) and (meal_type == MealType.BURGER):
		return false # The lower part is not visible
	if (container_type == ContainerType.BOWL) and (meal_type == MealType.NON_BURGER) and (non_burger_component_bottom != ""):
		return false # The lower part is not visible
	if (meal_type == MealType.NON_BURGER) and (non_burger_component_top != "") and Ingredients.ingredient_has_tag(non_burger_component_top, "flag"):
		return false # The flag doesn't fit in non-burgers :)
	if (meal_type == MealType.SOUP) and (container_type == ContainerType.PLATE):
		return false # a soup in a plate is not valid
	return true

func randomize_with_n_ingredients(n):
	randomize_with_min_max_ingredients(n, n)
	
	assert(get_element_count() <= n)

func randomize_with_at_most_n_ingredients(n):
	randomize_with_min_max_ingredients(1, n)
	
	assert(get_element_count() <= n)

func randomize_with_min_max_ingredients(_min, _max):
	assert(_max >= _min)
	assert(_min >= 1)
	assert(_max <= 4)

	while true:
		self.randomize()
		if (get_element_count() >= _min) and (get_element_count() <= _max):
			break

func randomize():
	while true:
		container_type = _randomize_dish_container()
		meal_type = _randomize_dish_meal_type();
		if meal_type == MealType.BURGER:
			_randomize_burger()
		elif meal_type == MealType.SOUP:
			_randomize_soup()
		else:
			assert(meal_type == MealType.NON_BURGER)
			_randomize_non_burger()
		if is_valid():
			break

func make_from_linear_ingredients(_container_type, ingredients):
	container_type = _container_type
	assert(ingredients.size() == 4)

	if ingredients[0] == "":
		meal_type = MealType.NON_BURGER
	elif Ingredients.is_bottom_burger_ingredient(ingredients[0]):
		meal_type = MealType.BURGER
	elif Ingredients.is_soup_base_ingredient(ingredients[0]):
		meal_type = MealType.SOUP
	else:
		meal_type = MealType.NON_BURGER

	if meal_type == MealType.BURGER:
		burger_component_bottom_burger = ingredients[0]
		burger_component_mid_burger = ingredients[1]
		burger_component_top_burger = ingredients[2]
		burger_component_top = ingredients[3]
	elif meal_type == MealType.SOUP:
		soup_component_base = ingredients[0]
		soup_component_top = ingredients[1]
		if ingredients[2] != "":
			return false
		if ingredients[3] != "":
			return false
	else:
		assert(meal_type == MealType.NON_BURGER)
		non_burger_component_bottom = ingredients[0]
		non_burger_component_main = ingredients[1]
		non_burger_component_top = ingredients[2]
		if ingredients[3] != "":
			return false

	return is_valid()


# I can't manage to send Dish through RPC so I serialize it in a dumb way
func serialize() -> Array:
	assert(is_valid())

	var result = []
	result.append(container_type)
	result.append(meal_type)

	if meal_type == MealType.BURGER:
		result.append(burger_component_bottom_burger)
		result.append(burger_component_mid_burger)
		result.append(burger_component_top_burger)
		result.append(burger_component_top)
	elif meal_type == MealType.SOUP:
		result.append(soup_component_base)
		result.append(soup_component_top)
		result.append("")
		result.append("")
	else:
		assert(meal_type == MealType.NON_BURGER)
		result.append(non_burger_component_bottom)
		result.append(non_burger_component_main)
		result.append(non_burger_component_top)
		result.append("")
	assert(result.size() == 6)
	return result

func deserialize(stream : Array):
	assert(stream.size() == 6)

	container_type = stream[0]
	meal_type = stream[1]

	if meal_type == MealType.BURGER:
		burger_component_bottom_burger = stream[2]
		burger_component_mid_burger = stream[3]
		burger_component_top_burger = stream[4]
		burger_component_top = stream[5]
	elif meal_type == MealType.SOUP:
		soup_component_base = stream[2]
		soup_component_top = stream[3]
		assert(stream[4] == "")
		assert(stream[5] == "")
	else:
		assert(meal_type == MealType.NON_BURGER)
		non_burger_component_bottom = stream[2]
		non_burger_component_main = stream[3]
		non_burger_component_top = stream[4]
		assert(stream[5] == "")
	assert(is_valid())

static func _compute_ingredient_difference(ing0, ing1):
	Global.logger_raw("_compute_ingredient_difference(" + ing0 + ing1 + ") -> ")
	if (ing0 == ing1 and ing0 != ""):
		Global.logger("same (2)")
		return 2
	if (ing0 == ing1 and ing0 == ""):
		Global.logger("same (-1)")
		return -1
	if (ing0 == "") or (ing1 == ""):
		Global.logger("different (0)")
		return 0

	var desc0 : Ingredients.IngredientDesc = Ingredients.get_ingredient_desc(ing0)
	var desc1 : Ingredients.IngredientDesc = Ingredients.get_ingredient_desc(ing1)
	assert(desc0 != null)
	assert(desc1 != null)
	assert(desc0 != desc1)

	var common_tags = Global.intersect_2_lists(desc0.tags, desc1.tags)
	if not common_tags.empty():
		Global.logger("same tag (1)")
		return 1

	var common_plain_keywords = Global.intersect_2_lists(desc0.plain_keywords_fr, desc1.plain_keywords_fr)
	if not common_plain_keywords.empty():
		Global.logger("same keyword (1)")
		return 1
	Global.logger("different (0)")
	return 0

# return a [ing0, ing1, ing2, ing3] array
# ing can be -1 (both null), 0 (very different), 1 (different but...) or 2 (equal)
static func compute_difference(dish0 : Dish, dish1 : Dish):
	var linear_dish0 = dish0.serialize();
	var linear_dish1 = dish1.serialize();
	
	var result = []
	for i in range(4):
		var ing_diff = _compute_ingredient_difference(linear_dish0[i + 2], linear_dish1[i + 2])
		result.append(ing_diff)
	return result;
	
func debug_print():
	Global.logger("Container: " + str(ContainerType.keys()[container_type]))
	Global.logger("Meal: " + str(MealType.keys()[meal_type]))
	if meal_type == MealType.BURGER:
		Global.logger("Burger bottom: " + burger_component_bottom_burger)
		Global.logger("Burger mid: " + burger_component_mid_burger)
		Global.logger("Burger top: " + burger_component_top_burger)
		Global.logger("Top: " + burger_component_top)
	elif meal_type == MealType.SOUP:
		Global.logger("Soup base: " + soup_component_base)
		Global.logger("Soup top: " + soup_component_top)
	else:
		assert(meal_type == MealType.NON_BURGER)
		Global.logger("Bottom: " + non_burger_component_bottom)
		Global.logger("Main: " + non_burger_component_main)
		Global.logger("Top: " + non_burger_component_top)
