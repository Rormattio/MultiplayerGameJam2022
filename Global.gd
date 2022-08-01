extends Node

signal cheffe_dish_sent(dish)
signal waiter_command_sent(Order)
signal patron_dish_score_sent(dish, score)

var DEBUG = true

var id_counter = 0

# TODO : Remove
var bottom_ingredients = [
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

# TODO : Remove
var top_ingredients = [
]

# TODO : Remove
var bottom_burger_ingredients = [
]

# TODO : Remove
var mid_burger_ingredients = [
]

# TODO : Remove
var top_burger_ingredients = [
]

# TODO : Remove
var ingredient_names = [
]

enum Sfx {
	SPLOTCH,
	POP,
	TENTACLE,
	FFFT,
	SHHOO,
	CLICK,
	SCHBOING
}

# TODO : Remove
var ingredient_names_to_sfx = {
}

class IngredientDesc:
	var name
	var tags
	var plain_keywords_fr
	var obscure_keywords_fr
	var sfx

	func has_tag(tag):
		return tags.has(tag)

	func has_any_tag(tag_list):
		for t in tag_list:
			if tags.has(t):
				return true
		return false

	func _init(n, t, pk, ok, s):
		name = n
		tags = t
		plain_keywords_fr = pk
		obscure_keywords_fr = pk
		sfx  = s

var ingredient_descs = [
	IngredientDesc.new("black_forest_hole", [],
		["black"], [],
		null),
	IngredientDesc.new("blue_banana", [],
		["blue"], [],
		null),
	IngredientDesc.new("bread", ["bottom_burger"],
		["bread", "bottom"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_blue", ["bottom_burger"],
		["bread", "blue", "bottom"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_green", ["bottom_burger"],
		["bread", "green", "bottom"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_grey", ["bottom_burger"],
		["bread", "grey", "bottom"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_top", ["top_burger"],
		["bread", "top"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_top_blue", ["top_burger"],
		["bread", "blue", "top"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_top_green", ["top_burger"],
		["bread", "green", "top"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_top_grey", ["top_burger"],
		["bread", "grey", "top"], [],
		Sfx.FFFT),
	IngredientDesc.new("crab", ["mid_burger"],
		[], [],
		null),
	IngredientDesc.new("flag_blue", ["top", "flag"],
		["flag", "blue"], [],
		null),
	IngredientDesc.new("flag_fr", ["top", "flag"],
		["flag"], [],
		null),
	IngredientDesc.new("flag_yellow", ["top", "flag"],
		["flag", "yellow"], [],
		null),
	IngredientDesc.new("ghosts", [],
		[], [],
		null),
	IngredientDesc.new("puree_grumpy", ["bottom"],
		["puree"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("puree_happy", ["bottom"],
		["puree"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("puree_mighty", ["bottom"],
		["puree"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("puree_smirky", ["bottom"],
		["puree"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("puree_worried", ["bottom"],
		["puree"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("mecha_ham", [],
		[], [],
		null),
	IngredientDesc.new("planet_earth", ["mid_burger"],
		["planet", "blue", "round"], [],
		Sfx.POP),
	IngredientDesc.new("planet_jupiter", ["mid_burger"],
		["planet", "orange", "round"], [],
		Sfx.POP),
	IngredientDesc.new("planet_mars", ["mid_burger"],
		["planet", "red", "round"], [],
		Sfx.POP),
	IngredientDesc.new("planet_neptune", ["mid_burger"],
		["planet", "blue", "round"], [],
		Sfx.POP),
	IngredientDesc.new("planet_saturn", ["mid_burger"],
		["planet", "rings", "round"], [],
		Sfx.POP),
	IngredientDesc.new("smoke_green", ["top"],
		["smoke", "green"], [],
		Sfx.SHHOO),
	IngredientDesc.new("smoke_kaki", ["top"],
		["smoke", "kaki"], [],
		Sfx.SHHOO),
	IngredientDesc.new("smoke_orange", ["top"],
		["smoke", "orange"], [],
		Sfx.SHHOO),
	IngredientDesc.new("smoke_pink", ["top"],
		["smoke", "pink"], [],
		Sfx.SHHOO),
	IngredientDesc.new("smoke_purple", ["top"],
		["smoke", "purple"], [],
		Sfx.SHHOO),
	IngredientDesc.new("springs", [],
		[], [],
		Sfx.SCHBOING),
	IngredientDesc.new("squid_green", [],
		["squid", "green"], [],
		Sfx.TENTACLE),
	IngredientDesc.new("squid_space", [],
		["squid"], [],
		Sfx.TENTACLE),
	IngredientDesc.new("squid_yellow", [],
		["squid", "yellow"], [],
		Sfx.TENTACLE),
	IngredientDesc.new("stars_blue", ["top"],
		["stars", "blue"], [],
		null),
	IngredientDesc.new("stars_green", ["top"],
		["stars", "green"], [],
		null),
	IngredientDesc.new("stars_pink", ["top"],
		["stars", "pink"], [],
		null),
	IngredientDesc.new("stars_purple", ["top"],
		["stars", "purple"], [],
		null),
	IngredientDesc.new("stars_yellow", ["top"],
		["stars", "yellow"], [],
		null),
]

func get_ingredient_desc(name):
	for desc in ingredient_descs:
		if desc.name == name:
			return desc
	return null

func ingredient_has_tag(name, flag):
	return get_ingredient_desc(name).has_tag(flag)

func get_ingredient_names_with_tag(tag):
	var result = []
	for desc in ingredient_descs:
		if desc.has_tag(tag):
			result.append(desc.name)
	return result

func get_ingredient_count():
	return ingredient_descs.size()

func is_ingredient(name):
	return get_ingredient_desc(name) != null

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
	# Build ingredient_names for bw-compat
	for desc in ingredient_descs:
		ingredient_names.append(desc.name)

	# Build ingredient_names_to_sfx for bw-compat
	for desc in ingredient_descs:
		if desc.sfx != null:
			ingredient_names_to_sfx[desc.name] = desc.sfx

	# Build bottom_ingredients for bw-compat
	bottom_ingredients = get_ingredient_names_with_tag("bottom")

	# Build top_ingredients for bw-compat
	top_ingredients = get_ingredient_names_with_tag("top")

	# Build bottom_burger_ingredients for bw-compat
	bottom_burger_ingredients = get_ingredient_names_with_tag("bottom_burger")

	# Build mid_burger_ingredients for bw-compat
	mid_burger_ingredients = get_ingredient_names_with_tag("mid_burger")

	# Build top_burger_ingredients for bw-compat
	top_burger_ingredients = get_ingredient_names_with_tag("top_burger")

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

func cheffe_send_dish(dish : Array):
	rpc("on_cheffe_dish", dish)

remote func on_cheffe_dish(dish : Array):
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
