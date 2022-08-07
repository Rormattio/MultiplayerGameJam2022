extends Node

signal cheffe_dish_sent(dish, dish_idx, order_serialized)
signal cheffe_dish_trashed(dish_index)
signal waiter_command_sent(Order)
signal waiter_dish_taken(dish_index)
signal patron_dish_score_sent(dish_serialized, score, order_serialized, hints)
signal lobby_role_sent(role)
signal lobby_start_game_sent()
signal player_quit_sent(id)
signal on_score_sent(total_score)

var DEBUG = false

const MAX_DISH_ON_COUNTER = 6

var id_counter = 0

var plain_keywords_set = []
var plain_keywords_occurrences = {}
var plain_keywords_reachability = {}

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
		if Ingredients.plain_keywords_synonyms.has(kw):
			var alternatives = Ingredients.plain_keywords_synonyms[kw]
			var choice = randi() % (alternatives.size() + 1)
			if choice != 0:
				result[i] = alternatives[choice - 1]

	return result

# What do you mean, "complexity" ? Never heard about this
func intersect_2_lists(la, lb):
	var result = []
	for a in la:
		if lb.has(a):
			result.append(a)
	return result

func intersect_3_lists(la, lb, lc):
	return intersect_2_lists(intersect_2_lists(la, lb), lc)

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

					var reachable_by_pair = intersect_2_lists(reachable_by_first_kw, reachable_by_second_kw)
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

							var reachable_by_triplet = intersect_3_lists(reachable_by_first_kw, reachable_by_second_kw, reachable_by_third_kw)

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
	Ingredients._ready()

	Ingredients._check_ingredient_metadata()

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

func cheffe_send_dish(dish : Array, dish_idx : int, order_serialized):
	rpc("on_cheffe_dish", dish, dish_idx, order_serialized)

remote func on_cheffe_dish(dish : Array, dish_idx : int, order_serialized):
	emit_signal("cheffe_dish_sent", dish, dish_idx, order_serialized)

func cheffe_trashed_dish(dish_idx : int):
	rpc("on_cheffe_trashed_dish", dish_idx)

remote func on_cheffe_trashed_dish(dish_idx : int):
	emit_signal("cheffe_dish_trashed", dish_idx)

func waiter_takes_dish(dish_index : int):
	rpc("on_waiter_dish", dish_index)

remote func on_waiter_dish(dish_index : int):
	emit_signal("waiter_dish_taken", dish_index)

func patron_send_dish_score(dish_serialized, score, order_serialized, hints):
	rpc("on_patron_dish_score_sent", dish_serialized, score, order_serialized, hints)

remote func on_patron_dish_score_sent(dish_serialized, score, order_serialized, hints):
	emit_signal("patron_dish_score_sent", dish_serialized, score, order_serialized, hints)
	
func send_score(score):
	emit_signal("on_score_sent", score) # For the Dining Room
	rpc("on_score_sent", score)         # For the Kitchen

remote func on_score_sent(score):
	emit_signal("on_score_sent", score)

func lobby_send_role(role):
	rpc("on_lobby_send_role", role)

remote func on_lobby_send_role(role):
	emit_signal("lobby_role_sent", role)

func lobby_send_start_game():
	rpc("on_lobby_send_start_game")

remote func on_lobby_send_start_game():
	emit_signal("lobby_start_game_sent")

func player_send_quit(id):
	rpc("on_player_send_quit", id)

remote func on_player_send_quit(id):
	emit_signal("player_quit_sent", id)

func rand_array(array : Array):
	return array[randi() % array.size()]

func gen_id() -> int:
	id_counter += 1
	return id_counter
