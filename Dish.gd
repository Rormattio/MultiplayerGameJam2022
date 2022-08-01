extends Object

# dish = (container, meal)
# container = bowl | plate
# meal = burger | non-burger
# non_burger = (bottom | _, main | _, top | _)
# burger = (bottom-burger, mid-burger, top-burger, top | _)

enum ContainerType { BOWL, PLATE }
enum MealType { BURGER, NON_BURGER }

var container_type
var meal_type

var burger_component_bottom_burger
var burger_component_mid_burger
var burger_component_top_burger
var burger_component_top

var non_burger_component_bottom
var non_burger_component_main
var non_burger_component_top

const BURGER_COMPONENT_TOP_PROBABILITY = 0.5
const NON_BURGER_COMPONENT_BOTTOM_PROBABILITY = 0.5
const NON_BURGER_COMPONENT_MAIN_PROBABILITY = 0.8
const NON_BURGER_COMPONENT_TOP_PROBABILITY = 0.5

func _randomize_dish_container():
	return ContainerType.get(ContainerType.keys()[randi() % ContainerType.size()])

func _randomize_dish_meal_type():
	return MealType.get(MealType.keys()[randi() % MealType.size()])
	
func _randomize_burger():
	assert(meal_type == MealType.BURGER)
	burger_component_bottom_burger = Global.bottom_burger_ingredients[randi() % Global.bottom_burger_ingredients.size()]
	burger_component_mid_burger = Global.mid_burger_ingredients[randi() % Global.mid_burger_ingredients.size()]
	burger_component_top_burger = Global.top_burger_ingredients[randi() % Global.top_burger_ingredients.size()]

	if randf() <= BURGER_COMPONENT_TOP_PROBABILITY:
		burger_component_top = Global.top_ingredients[randi() % Global.top_ingredients.size()]
	else:
		burger_component_top = ""
	return
	
func _randomize_non_burger():
	assert(meal_type == MealType.NON_BURGER)
	if randf() <= NON_BURGER_COMPONENT_BOTTOM_PROBABILITY:
		non_burger_component_bottom = Global.bottom_ingredients[randi() % Global.bottom_ingredients.size()]
	else:
		non_burger_component_bottom = ""

	if randf() <= NON_BURGER_COMPONENT_MAIN_PROBABILITY:
		non_burger_component_main = Global.main_ingredients[randi() % Global.main_ingredients.size()]
	else:
		non_burger_component_main = ""

	if randf() <= NON_BURGER_COMPONENT_TOP_PROBABILITY:
		non_burger_component_top = Global.top_ingredients[randi() % Global.top_ingredients.size()]
	else:
		non_burger_component_top = ""
	return

func is_valid():
	# Here we will prevent impossible combinations if necessary
	if (container_type == ContainerType.BOWL) and (meal_type == MealType.BURGER):
		return false # The lower part is not visible
	if (container_type == ContainerType.BOWL) and (meal_type == MealType.NON_BURGER) and (non_burger_component_bottom != ""):
		return false # The lower part is not visible
	return true

func make_unambiguous_token_list():
	var result = []
	result.append(ContainerType.keys()[container_type])
	result.append(MealType.keys()[meal_type])
	if meal_type == MealType.BURGER:
		result.append(burger_component_bottom_burger)
		result.append(burger_component_mid_burger)
		result.append(burger_component_top_burger)
		result.append(burger_component_top)
	else:
		assert(meal_type == MealType.NON_BURGER)
		result.append(non_burger_component_bottom)
		result.append(non_burger_component_main)
		result.append(non_burger_component_top)

	return result	
	
func randomize():
	while true:
		container_type = _randomize_dish_container()
		meal_type = _randomize_dish_meal_type();
		if meal_type == MealType.BURGER:
			_randomize_burger()
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
	elif Global.is_bottom_burger_ingredient(ingredients[0]):
		meal_type = MealType.BURGER
	else:
		meal_type = MealType.NON_BURGER

	if meal_type == MealType.BURGER:
		burger_component_bottom_burger = ingredients[0]
		burger_component_mid_burger = ingredients[1]
		burger_component_top_burger = ingredients[2]
		burger_component_top = ingredients[3]
	else:
		non_burger_component_bottom = ingredients[0]
		non_burger_component_main = ingredients[1]
		non_burger_component_top = ingredients[2]
		if ingredients[3] != "":
			return false
	
	return is_valid()

		
func debug_print():
	print("Container: ", ContainerType.keys()[container_type])
	print("Meal: ", MealType.keys()[meal_type])
	if meal_type == MealType.BURGER:
		print("Burger bottom: ", burger_component_bottom_burger)
		print("Burger mid: ", burger_component_mid_burger)
		print("Burger top: ", burger_component_top_burger)
		print("Top: ", burger_component_top)
	else:
		assert(meal_type == MealType.NON_BURGER)
		print("Bottom: ", non_burger_component_bottom)
		print("Main: ", non_burger_component_main)
		print("Top: ", non_burger_component_top)
	print("Unambiguous token list: ", make_unambiguous_token_list())
