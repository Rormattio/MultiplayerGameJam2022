extends Node

signal cheffe_dish_sent(dish)
signal cheffe_dish_trashed(dish_index)
signal waiter_command_sent(Order)
signal waiter_dish_taken(dish_index)
signal patron_dish_score_sent(dish, score)

var DEBUG = true

const MAX_DISH_ON_COUNTER = 6

var id_counter = 0

var bottom_ingredients = [
]

var main_ingredients = [
]

var top_ingredients = [
]

var bottom_burger_ingredients = [
]

var mid_burger_ingredients = [
]

var top_burger_ingredients = [
]

var ingredient_names = [
]

# TODO : Remove
var ingredient_names_to_sfx = {
}

const plain_keywords_synonyms = {
	"burger"   : ["sandwich"],
	"space"    : ["cosmic"],
	"creature" : ["meat"],
	"squid"    : ["tentacle"],
	"bottom"   : ["low"],
	"top"      : ["high"],
	"bread"    : ["bun"],
	"puree"    : ["mash"],
	"spaghetti": ["pasta", "noodles"],
	"fried"    : ["fat"],
	"eight"    : ["number"]
}

const obscure_keywords_synonyms = {
	"green"    : ["viridescent"],
	"creature" : ["organism"],
	"squid"    : ["pseudopod"],
	"ghosts"   : ["blinky", "pinky", "inky", "clyde"]
}

var plain_keywords_set = []
var plain_keywords_occurrences = {}
var plain_keywords_reachability = {}

func get_ingredient_desc(name):
	for desc in Ingredients.ingredient_descs:
		if desc.name == name:
			return desc
	return null

func ingredient_has_tag(name, flag):
	return get_ingredient_desc(name).has_tag(flag)

func get_ingredient_names_with_tag(tag):
	var result = []
	for desc in Ingredients.ingredient_descs:
		if desc.has_tag(tag):
			result.append(desc.name)
	return result

func get_ingredient_count():
	return Ingredients.ingredient_descs.size()

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

func _check_ingredient_metadata():
	var ingredient_count = get_ingredient_count()
	for i in range(ingredient_count):
		var name = ingredient_names[i]
		assert(is_ingredient(name))
		assert(is_bottom_ingredient(name) or is_main_ingredient(name) or is_top_ingredient(name) or
			is_bottom_burger_ingredient(name) or is_mid_burger_ingredient(name) or is_top_burger_ingredient(name))
		var png_name = "res://assets/food/" + name + ".png"
		assert(load(png_name) != null)
		
	for desc in Ingredients.ingredient_descs:
		var count = desc.plain_keywords_fr.size()
		assert(count >= 2)


func make_keyword_list(_seed : int):
	seed(_seed)

	print("make_keyword_list (seed : ", _seed, ")")
	
	var core_list = []
	# Initial seeding
	for desc in Ingredients.ingredient_descs:
		var ingredient = desc.name
		
		var reach_path_count = 0
		for kw in core_list:
			var reached_ingredients = Global.plain_keywords_reachability[kw]
			if reached_ingredients.has(ingredient):
				reach_path_count += 1
		
		if reach_path_count >= 2:
			continue
		
		var new_kw = null;
		while true:
			new_kw = desc.plain_keywords_fr[randi() % desc.plain_keywords_fr.size()]

			if not core_list.has(new_kw):
				break
		core_list.append(new_kw)
	
	print("First keyword list seeding has ", core_list.size(), " elements")

	var result = []
	var smallest_result = null
	
	for try in range(100):
		result = core_list.duplicate()
		# Completing the list to make it sound
		while not check_optimal_solutions(result):
			#TODO : Better solution plz
			var kw_to_add = plain_keywords_set.duplicate();
			kw_to_add.shuffle()
			for kw in kw_to_add:
				if not result.has(kw):
					result.append(kw)
					break
		if (smallest_result == null) or result.size() < smallest_result.size():
			smallest_result = result.duplicate()
	
	check_optimal_solutions(result, true)
	# Use synonyms for variety
	for i in range(result.size()):
		var kw = result[i]
		if plain_keywords_synonyms.has(kw):
			var alternatives = plain_keywords_synonyms[kw]
			var choice = randi() % (alternatives.size() + 1)
			if choice != 0:
				result[i] = alternatives[choice - 1]
	
	return result

# What do you mean, "complexity" ? Never heard about this
func _intersect_2_lists(la, lb):
	var result = []
	for a in la:
		if lb.has(a):
			result.append(a)
	return result

func check_optimal_solutions(authorized_keywords, verbose = false) -> bool:
	var ok = true
	for desc in Ingredients.ingredient_descs:
		var plain_keywords = desc.plain_keywords_fr
		
		var uniquely_reachable_with_a_single_keyword = false
		for kw in plain_keywords:
			assert(plain_keywords_reachability[kw] != [])
			if authorized_keywords.has(kw) and (plain_keywords_reachability[kw].size() == 1):
				if verbose:
					print("INFO: ", desc.name, " is uniquely reachable with single keyword ", kw, " (that is ok though, but maybe too easy?)")
				uniquely_reachable_with_a_single_keyword = true
		
		if not uniquely_reachable_with_a_single_keyword:
			var uniquely_reachable_with_two_keywords = false
			for i in range(plain_keywords.size()):
				if not authorized_keywords.has(plain_keywords[i]):
					continue
				var reachable_by_first_kw = plain_keywords_reachability[plain_keywords[i]]
				for j in range(i):
					if not authorized_keywords.has(plain_keywords[j]):
						continue
					var reachable_by_second_kw = plain_keywords_reachability[plain_keywords[j]]
					
					var reachable_by_pair = _intersect_2_lists(reachable_by_first_kw, reachable_by_second_kw)					
					if reachable_by_pair.size() == 1:
						assert(desc.name == reachable_by_pair[0])
						uniquely_reachable_with_two_keywords = true
						#TODO break out of this shit
		
			# Still not caring about this O() bullshit :p
			if not uniquely_reachable_with_two_keywords:
				var uniquely_reachable_with_three_keywords = false	
				for i in range(plain_keywords.size()):
					if not authorized_keywords.has(plain_keywords[i]):
						continue
					var reachable_by_first_kw = plain_keywords_reachability[plain_keywords[i]]
					for j in range(i):
						if not authorized_keywords.has(plain_keywords[j]):
							continue
						var reachable_by_second_kw = plain_keywords_reachability[plain_keywords[j]]
						for k in range(j):
							if not authorized_keywords.has(plain_keywords[k]):
								continue
							var reachable_by_third_kw = plain_keywords_reachability[plain_keywords[k]]
							
							var reachable_by_triplet = _intersect_2_lists(_intersect_2_lists(reachable_by_first_kw, reachable_by_second_kw), reachable_by_third_kw)
							
							if reachable_by_triplet.size() == 1:
								assert(desc.name == reachable_by_triplet[0])
								uniquely_reachable_with_three_keywords = true
								#TODO break out of this shit
				
				if uniquely_reachable_with_three_keywords:
					if verbose:
						print("WARNING: ", desc.name, "(", desc.plain_keywords_fr, ") is not uniquely reachable with a keyword pair")
				else:
					if verbose:
						print("ERROR: ", desc.name, "(", desc.plain_keywords_fr, ") is not uniquely reachable with a keyword triplet")
					ok = false
	return ok
	
func _ready():
	# Build ingredient_names for bw-compat
	for desc in Ingredients.ingredient_descs:
		ingredient_names.append(desc.name)

	# Build ingredient_names_to_sfx for bw-compat
	for desc in Ingredients.ingredient_descs:
		if desc.sfx != null:
			ingredient_names_to_sfx[desc.name] = desc.sfx

	# Build bottom_ingredients for bw-compat
	bottom_ingredients = get_ingredient_names_with_tag("bottom")

	# Build main_ingredients for bw-compat
	main_ingredients = get_ingredient_names_with_tag("main")

	# Build top_ingredients for bw-compat
	top_ingredients = get_ingredient_names_with_tag("top")

	# Build bottom_burger_ingredients for bw-compat
	bottom_burger_ingredients = get_ingredient_names_with_tag("bottom_burger")

	# Build mid_burger_ingredients for bw-compat
	mid_burger_ingredients = get_ingredient_names_with_tag("mid_burger")

	# Build top_burger_ingredients for bw-compat
	top_burger_ingredients = get_ingredient_names_with_tag("top_burger")

	_check_ingredient_metadata()

	# Compute reachability	
	plain_keywords_set = []
	for desc in Ingredients.ingredient_descs:
		for kw in desc.plain_keywords_fr:
			if not plain_keywords_set.has(kw):
				plain_keywords_set.append(kw)
			
			var count = plain_keywords_occurrences.get(kw, 0)
			count += 1
			plain_keywords_occurrences[kw] = count

			var reachability = plain_keywords_reachability.get(kw, [])
			reachability.append(desc.name)
			plain_keywords_reachability[kw] = reachability
	
	plain_keywords_set.sort()		
	#print("plain_keywords_occurrences: ", plain_keywords_occurrences)
	#print("plain_keywords_reachability: ", plain_keywords_reachability)

	var ok = check_optimal_solutions(plain_keywords_set, true)
	assert(ok)
		
	randomize()
	var _seed = randi()
	var keyword_list = make_keyword_list(_seed)
	print("keyword_list: ", keyword_list)

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

func cheffe_send_dish(dish : Array, dish_idx : int):
	rpc("on_cheffe_dish", dish, dish_idx)

remote func on_cheffe_dish(dish : Array, dish_idx : int):
	emit_signal("cheffe_dish_sent", dish, dish_idx)

func cheffe_trashed_dish(dish_idx : int):
	rpc("on_cheffe_trashed_dish", dish_idx)

remote func on_cheffe_trashed_dish(dish_idx : int):
	emit_signal("cheffe_dish_trashed", dish_idx)

func waiter_takes_dish(dish_index : int):
	rpc("on_waiter_dish", dish_index)

remote func on_waiter_dish(dish_index : int):
	emit_signal("waiter_dish_taken", dish_index)

func patron_send_dish_score(dish, score):
	rpc("on_patron_dish_score_sent", dish, score)

remote func on_patron_dish_score_sent(dish, score):
	emit_signal("patron_dish_score_sent", dish, score)

func rand_array(array : Array):
	return array[randi() % array.size()]

func gen_id() -> int:
	id_counter += 1
	return id_counter
