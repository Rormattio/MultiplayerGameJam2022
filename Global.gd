extends Node

signal cheffe_dish_sent(dish)
signal waiter_command_sent(command)

var bottom_ingredients = [
	"grumpy_puree",
	"happy_puree",
	"mighty_puree",
	"smirky_puree",
	"worried_puree",
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
	"grumpy_puree",
	"happy_puree",
	"mecha_ham",
	"mighty_puree",
	"planet_earth",
	"planet_jupiter",
	"planet_mars",
	"planet_neptune",
	"planet_saturn",
	"smirky_puree",
	"springs",
	"squid_green",
	"squid_space",
	"squid_yellow",
	"worried_puree",
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
	"grumpy_puree",
	"happy_puree",
	"mecha_ham",
	"mighty_puree",
	"planet_earth",
	"planet_jupiter",
	"planet_mars",
	"planet_neptune",
	"planet_saturn",
	"smirky_puree",
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
	"worried_puree",
]

func _ready():
	randomize()

func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

func waiter_send_command(command):
	rpc("on_waiter_command", command)

remote func on_waiter_command(command):
	emit_signal("waiter_command_sent", command)

func cheffe_send_dish(dish):
	rpc("on_cheffe_dish", dish)

remote func on_cheffe_dish(dish):
	emit_signal("cheffe_dish_sent", dish)

func rand_array(array : Array):
	return array[randi() % array.size()]
