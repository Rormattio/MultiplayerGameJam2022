extends Node

signal cheffe_dish_sent(dish)
signal waiter_command_sent(Order)
signal patron_dish_score_sent(dish, score)

var DEBUG = true

var id_counter = 0

var bottom_ingredients = [
	"puree_grumpy",
	"puree_happy",
	"puree_mighty",
	"puree_smirky",
	"puree_worried",
]

var main_ingredients = [
	"black_forest_hole",
	"blue_banana",
	"crab",
	"ghosts",
	"mecha_ham",
	"planet_earth",
	"planet_jupiter",
	"planet_mars",
	"planet_neptune",
	"planet_saturn",
	"springs",
	"squid_green",
	"squid_space",
	"squid_yellow",
]

var top_ingredients = [
	"flag_blue",
	"flag_fr",
	"flag_yellow",
	"smoke_green",
	"smoke_kaki",
	"smoke_orange",
	"smoke_pink",
	"smoke_purple",
	"stars_blue",
	"stars_green",
	"stars_pink",
	"stars_purple",
	"stars_yellow",
]

var bottom_burger_ingredients = [
	"bread",
	"bread_blue",
	"bread_green",
	"bread_grey",
]

var mid_burger_ingredients = [
	"crab",
	"planet_earth",
	"planet_jupiter",
	"planet_mars",
	"planet_neptune",
	"planet_saturn",
]

var top_burger_ingredients = [
	"bread_top",
	"bread_top_blue",
	"bread_top_green",
	"bread_top_grey",
]

var base_ingredient_names = [
	"black_forest_hole",
	"blue_banana",
	"bread",
	"bread_blue",
	"bread_green",
	"bread_grey",
	"bread_top",
	"bread_top_blue",
	"bread_top_green",
	"bread_top_grey",
	"crab",
	"ghosts",
	"puree_grumpy",
	"puree_happy",
	"puree_mighty",
	"puree_smirky",
	"puree_worried",
	"mecha_ham",
	"planet_earth",
	"planet_jupiter",
	"planet_mars",
	"planet_neptune",
	"planet_saturn",
	"springs",
	"squid_green",
	"squid_space",
	"squid_yellow",
]

var ingredient_names = [
	"black_forest_hole",
	"blue_banana",
	"bread",
	"bread_blue",
	"bread_green",
	"bread_grey",
	"bread_top",
	"bread_top_blue",
	"bread_top_green",
	"bread_top_grey",
	"crab",
	"flag_blue",
	"flag_fr",
	"flag_yellow",
	"ghosts",
	"puree_grumpy",
	"puree_happy",
	"puree_mighty",
	"puree_smirky",
	"puree_worried",
	"mecha_ham",
	"planet_earth",
	"planet_jupiter",
	"planet_mars",
	"planet_neptune",
	"planet_saturn",
	"smoke_green",
	"smoke_kaki",
	"smoke_orange",
	"smoke_pink",
	"smoke_purple",
	"springs",
	"squid_green",
	"squid_space",
	"squid_yellow",
	"stars_blue",
	"stars_green",
	"stars_pink",
	"stars_purple",
	"stars_yellow",
]

enum Sfx {
	SPLOTCH,
	POP,
	TENTACLE,
	FFFT,
	SHHOO,
	CLICK,
}

var ingredient_names_to_sfx = {
	"bread"             : Sfx.FFFT,
	"bread_blue"		: Sfx.FFFT,
	"bread_green"		: Sfx.FFFT,
	"bread_grey"		: Sfx.FFFT,
	"bread_top"		    : Sfx.FFFT,
	"bread_top_blue"	: Sfx.FFFT,
	"bread_top_green"	: Sfx.FFFT,
	"bread_top_grey"	: Sfx.FFFT,
	"puree_grumpy"		: Sfx.SPLOTCH,
	"puree_happy"		: Sfx.SPLOTCH,
	"puree_mighty"		: Sfx.SPLOTCH,
	"puree_smirky"		: Sfx.SPLOTCH,
	"puree_worried"		: Sfx.SPLOTCH,
	"planet_earth"		: Sfx.POP,
	"planet_jupiter"	: Sfx.POP,
	"planet_mars"		: Sfx.POP,
	"planet_neptune"	: Sfx.POP,
	"planet_saturn"		: Sfx.POP,
	"squid_green"       : Sfx.TENTACLE,
	"squid_space"       : Sfx.TENTACLE,
	"squid_yellow"      : Sfx.TENTACLE,
	"smoke_green"       : Sfx.SHHOO,
	"smoke_kaki"        : Sfx.SHHOO,
	"smoke_orange"      : Sfx.SHHOO,
	"smoke_pink"        : Sfx.SHHOO,
	"smoke_purple"      : Sfx.SHHOO,
}




func get_ingredient_count():
	return ingredient_names.size()

func is_ingredient(name):
	return ingredient_names.has(name)

func is_bottom_ingredient(name):
	assert(is_ingredient(name))
	return bottom_ingredients.has(name)

func is_main_ingredient(name):
	assert(is_ingredient(name))
	return main_ingredients.has(name)

func is_top_ingredient(name):
	assert(is_ingredient(name))
	return top_ingredients.has(name)

func is_bottom_burger_ingredient(name):
	assert(is_ingredient(name))
	return bottom_burger_ingredients.has(name)

func is_mid_burger_ingredient(name):
	assert(is_ingredient(name))
	return mid_burger_ingredients.has(name)

func is_top_burger_ingredient(name):
	assert(is_ingredient(name))
	return top_burger_ingredients.has(name)

func check_ingredient_metadata():
	var ingredient_count = get_ingredient_count()
	for i in range(ingredient_count):
		var name = ingredient_names[i]
		assert(is_ingredient(name))
		assert(is_bottom_ingredient(name) or is_main_ingredient(name) or is_top_ingredient(name) or
			   is_bottom_burger_ingredient(name) or is_mid_burger_ingredient(name) or is_top_burger_ingredient(name))
		var png_name = "res://assets/food/" + name + ".png"
		assert(load(png_name) != null)

func _ready():
	check_ingredient_metadata()
	randomize()

func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

func waiter_send_command(command: Order):
	rpc("on_waiter_command", command.serialize())

remote func on_waiter_command(command: Array):
	var order = Order.new()
	order.unserialize(command)
	emit_signal("waiter_command_sent", order)

func cheffe_send_dish(dish):
	rpc("on_cheffe_dish", dish)

remote func on_cheffe_dish(dish):
	emit_signal("cheffe_dish_sent", dish)

func patron_send_dish_score(dish, score):
	rpc("on_patron_dish_score_sent", dish, score)

remote func on_patron_dish_score_sent(dish, score):
	emit_signal("patron_dish_score_sent", dish, score)

func rand_array(array : Array):
	return array[randi() % array.size()]

func gen_id() -> int:
	id_counter += 1
	return id_counter
