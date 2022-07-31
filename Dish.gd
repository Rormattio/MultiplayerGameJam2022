extends Object

# dish = (container, meal)
# container = bowl | plate
# meal = 5burger | non-burger
# non_burger = (bottom | _, main | _, top | _)
# burger = (bottom-burger, mid-burger, top-burger, top | _)

enum ContainerType { BOWL, PLATE }
enum MealType { BURGER, NON_BURGER }

var containerType
var mealType

var burger_component_bottom_burger
var burger_component_mid_burger
var burger_component_top_burger
var burger_component_top

var non_burger_component_bottom
var non_burger_component_main
var non_burger_component_top

func randomize_dish_container():
	return ContainerType.get(ContainerType.keys()[randi() % ContainerType.size()])

func randomize_dish_meal_type():
	return MealType.get(MealType.keys()[randi() % MealType.size()])
	
func randomize_burger():
	assert(mealType == MealType.BURGER)
	burger_component_bottom_burger = Global.bottom_burger_ingredients[randi() % Global.bottom_burger_ingredients.size()]
	burger_component_mid_burger = Global.mid_burger_ingredients[randi() % Global.mid_burger_ingredients.size()]
	burger_component_top_burger = Global.top_burger_ingredients[randi() % Global.top_burger_ingredients.size()]

	burger_component_top = Global.top_ingredients[randi() % Global.top_ingredients.size()]
	return
	
func randomize_non_burger():
	assert(mealType == MealType.NON_BURGER)
	# TODO optional bottom and top
	non_burger_component_bottom = Global.bottom_ingredients[randi() % Global.bottom_ingredients.size()]
	non_burger_component_main = Global.main_ingredients[randi() % Global.main_ingredients.size()]

	non_burger_component_top = Global.top_ingredients[randi() % Global.top_ingredients.size()]
	return

func randomize():
	containerType = randomize_dish_container()
	mealType = randomize_dish_meal_type();
	if mealType == MealType.BURGER:
		randomize_burger()
	else:
		assert(mealType == MealType.NON_BURGER)
		randomize_non_burger()

func debug_print():
	print("Container: ", ContainerType.keys()[containerType])
	print("Meal: ", MealType.keys()[mealType])
	if mealType == MealType.BURGER:
		print("Burger bottom: ", burger_component_bottom_burger)
		print("Burger mid: ", burger_component_mid_burger)
		print("Burger top: ", burger_component_top_burger)
		print("Top: ", burger_component_top)
	else:
		assert(mealType == MealType.NON_BURGER)
		print("Non-burger bottom: ", non_burger_component_bottom)
		print("Non-burger main: ", non_burger_component_main)
		print("Non-burger top: ", non_burger_component_top)
