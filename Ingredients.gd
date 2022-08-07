extends Node

enum Sfx {
	SPLOTCH,
	POP,
	TENTACLE,
	FFFT,
	SHHOO,
	CLICK,
	SCHBOING,
	WHOOO
}

var tag_set = [ "main", "bottom_burger", "mid_burger", "top_burger", "top", "flag", "bottom", "soup_base", "soup_top" ]

class IngredientDesc:
	var name
	var tags
	var plain_keywords_fr
	var obscure_keywords_fr
	var sfx
	
	var png

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
		obscure_keywords_fr = ok
		sfx  = s

var ingredient_descs = [
	IngredientDesc.new("black_forest_hole", ["main"],
		["black", "space", "fruit"], [],
		null),
	IngredientDesc.new("banana_blue", ["main"],
		["blue", "vegetal", "fruit"], [],
		null),
	IngredientDesc.new("banana_green", ["main"],
		["green", "vegetal", "fruit"], [],
		null),
	IngredientDesc.new("banana_red", ["main"],
		["red", "vegetal", "fruit"], [],
		null),
	IngredientDesc.new("bread", ["bottom_burger"],
		["bread", "bottom", "burger", "plain"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_blue", ["bottom_burger"],
		["bread", "blue", "bottom", "burger"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_green", ["bottom_burger"],
		["bread", "green", "bottom", "burger"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_grey", ["bottom_burger"],
		["bread", "grey", "bottom", "burger"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_top", ["top_burger"],
		["bread", "top", "burger", "plain"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_top_blue", ["top_burger"],
		["bread", "blue", "top", "burger"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_top_green", ["top_burger"],
		["bread", "green", "top", "burger"], [],
		Sfx.FFFT),
	IngredientDesc.new("bread_top_grey", ["top_burger"],
		["bread", "grey", "top", "burger"], [],
		Sfx.FFFT),
	IngredientDesc.new("brochette_eyes", ["main"],
		["eyeballs", "skewer", "white"], [], 
		Sfx.POP),
	IngredientDesc.new("brochette_eyes_pink", ["main"],
		["eyeballs", "skewer", "pink"], [], 
		Sfx.POP),
	IngredientDesc.new("crab", ["mid_burger", "main"],
		["creature", "claws", "red"], [],
		null),
	IngredientDesc.new("crab_kaki", ["mid_burger", "main"],
		["creature", "claws", "khaki"], [],
		null),
	IngredientDesc.new("flag_blue", ["top", "flag"],
		["flag", "blue"], [],
		null),
	IngredientDesc.new("flag_fr", ["top", "flag"],
		["flag", "french"], [],
		null),
	IngredientDesc.new("flag_yellow", ["top", "flag"],
		["flag", "yellow", "happy"], [],
		null),
	IngredientDesc.new("ghosts", ["main"],
		["ghost", "skewer"], [],
		Sfx.WHOOO),
	IngredientDesc.new("ghost_robot", ["main"],
		["ghost", "mechanical"], [],
		Sfx.WHOOO),
	IngredientDesc.new("puree_grumpy", ["bottom"],
		["puree", "grumpy"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("puree_happy", ["bottom"],
		["puree", "happy"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("puree_mighty", ["bottom"],
		["puree", "mighty"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("puree_smirky", ["bottom"],
		["puree", "smirky"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("puree_worried", ["bottom"],
		["puree", "worried"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("spaghetti_eyeballs", ["bottom"],
		["spaghetti", "eyeballs", "plain"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("spaghetti_eyeballs_red", ["bottom"],
		["spaghetti", "eyeballs", "red"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("spaghetti_eyeballs_grey", ["bottom"],
		["spaghetti", "eyeballs", "grey"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("mecha_ham", ["main"],
		["creature", "mechanical"], [],
		null),
	IngredientDesc.new("planet_earth", ["mid_burger", "main"],
		["planet", "blue", "round", "space", "water"], [],
		Sfx.POP),
	IngredientDesc.new("planet_eight", ["mid_burger", "main"],
		["planet", "black", "round", "space", "eight"], [],
		Sfx.POP),
	IngredientDesc.new("planet_jupiter", ["mid_burger", "main"],
		["planet", "orange", "round", "space", "giant", "gas"], [],
		Sfx.POP),
	IngredientDesc.new("planet_mars", ["mid_burger", "main"],
		["planet", "red", "round", "space"], [],
		Sfx.POP),
	IngredientDesc.new("planet_neptune", ["mid_burger", "main"],
		["planet", "blue", "round", "space", "giant"], [],
		Sfx.POP),
	IngredientDesc.new("planet_saturn", ["mid_burger", "main"],
		["planet", "rings", "round", "space", "giant", "gas"], [],
		Sfx.POP),
	IngredientDesc.new("saturn_pane", ["main"],
		["planet", "rings", "fried", "space", "giant"], [],
		Sfx.FFFT),
	IngredientDesc.new("smoke_green", ["top"],
		["smoke", "green", "gas"], [],
		Sfx.SHHOO),
	IngredientDesc.new("smoke_kaki", ["top"],
		["smoke", "khaki", "gas"], [],
		Sfx.SHHOO),
	IngredientDesc.new("smoke_orange", ["top"],
		["smoke", "orange", "gas"], [],
		Sfx.SHHOO),
	IngredientDesc.new("smoke_pink", ["top"],
		["smoke", "pink", "gas"], [],
		Sfx.SHHOO),
	IngredientDesc.new("smoke_purple", ["top"],
		["smoke", "purple", "gas"], [],
		Sfx.SHHOO),
	IngredientDesc.new("springs", ["main"],
		["vegetal", "spiral"], [],
		Sfx.SCHBOING),
	IngredientDesc.new("squid_green", ["main"],
		["squid", "green", "creature"], [],
		Sfx.TENTACLE),
	IngredientDesc.new("squid_space", ["main"],
		["squid", "space", "creature"], [],
		Sfx.TENTACLE),
	IngredientDesc.new("squid_yellow", ["main"],
		["squid", "yellow", "creature"], [],
		Sfx.TENTACLE),
	IngredientDesc.new("stars_blue", ["top"],
		["stars", "blue", "space"], [],
		null),
	IngredientDesc.new("stars_green", ["top"],
		["stars", "green", "space"], [],
		null),
	IngredientDesc.new("stars_pink", ["top"],
		["stars", "pink", "space"], [],
		null),
	IngredientDesc.new("stars_purple", ["top"],
		["stars", "purple", "space"], [],
		null),
	IngredientDesc.new("stars_yellow", ["top"],
		["stars", "yellow", "space"], [],
		null),
	IngredientDesc.new("soup_water", ["soup_base"],
		["blue", "water", "soup"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("soup_lava", ["soup_base"],
		["red", "soup"], [],
		Sfx.SPLOTCH),
	IngredientDesc.new("parasol_yellow", ["soup_top"],
		["parasol", "yellow"], [],
		null),
	IngredientDesc.new("parasol_pink", ["soup_top"],
		["parasol", "pink"], [],
		null),
	IngredientDesc.new("sharks", ["soup_top"],
		["creature", "shark"], [],
		null),
	IngredientDesc.new("island", ["soup_top"],
		["island", "vegetal"], [],
		null)
]

const plain_keywords_synonyms = {
	"black" : ["obsidian", "dark"],
	"blue" : ["azure", "navy"],
	"bottom" : ["low", "under", "beneath"],
	"bread" : ["bun", "soft"],
	"burger" : ["sandwich", "club"],
	"claws" : ["clamp", "weaponized", "Krusty"],
	"creature" : ["meat", "living"],
	"eight" : ["number", "octo"],
	"eyeballs" : ["glancing"],
	"flag" : ["patriotic"],
	"french" : ["cuisine", "marseillaise", "retreat"],
	"fried" : ["fat", "sauteed"],
	"fruit" : ["sweet", "juicy"],
	"gas" : ["steam", "vapor"],
	"ghost" : ["ectoplasm", "ether"],
	"giant" : ["huge", "massive"],
	"green" : ["leafy"],
	"grey" : ["silvery"],
	"grumpy" : ["grouchy", "peevish"],
	"happy" : ["joyful", "glad"],
	"island" : ["isolated", "arhipelago"],
	"khaki" : ["camouflage", "green-ish"],
	"mechanical" : ["clockwork", "robot"],
	"mighty" : ["laureate"],
	"orange" : ["sunset", "apricot"],
	"parasol" : ["umbrella", "beach"],
	"pink" : ["blush", "coral"],
	"plain" : ["simple", "normal"],
	"planet" : ["orbit", "homeland"],
	"puree" : ["mash"],
	"purple" : ["violet"],
	"red" : ["rose", "blood"],
	"rings" : ["hoop", "donut"],
	"round" : ["sphere", "ball"],
	"shark" : ["fin"],
	"skewer" : ["souvlaki", "brochette"],
	"smirky" : ["insidious", "sneaky"],
	"smoke" : ["foggy", "deadly"],
	"soup" : ["broth", "chowder"],
	"space" : ["cosmic", "astral"],
	"spaghetti" : ["pasta", "noodles"],
	"spiral" : ["helix"],
	"squid" : ["tentacle", "squishy"],
	"stars" : ["shiny", "sparkling"],
	"top" : ["high", "up"],
	"vegetal" : ["plant", "greenery"],
	"water" : ["H2O", "liquid", "aqua"],
	"white" : ["blank", "snow"],
	"worried" : ["anxious"],
	"yellow" : ["banana", "sunny"],
}

const obscure_keywords_synonyms = {
	"green"    : ["viridescent"],
	"creature" : ["organism"],
	"squid"    : ["pseudopod"],
	"ghost"   : ["blinky", "pinky", "inky", "clyde"]
}
var ingredient_names = []
var plain_keywords = []

var bottom_ingredients = []
var main_ingredients = []
var top_ingredients = []
var bottom_burger_ingredients = []
var mid_burger_ingredients = []
var top_burger_ingredients = []
var soup_base_ingredients = []
var soup_top_ingredients = []

func _ready():
	# Build ingredient_names for bw-compat
	ingredient_names = []
	for desc in ingredient_descs:
		ingredient_names.append(desc.name)
		for kw in desc.plain_keywords_fr:
			if not plain_keywords.has(kw):
				plain_keywords.append(kw)
	ingredient_names.sort()
	plain_keywords.sort()
	print("Keywords: ", plain_keywords)
	
	# Build ingredient lists for bw-compat
	bottom_ingredients = get_ingredient_names_with_tag("bottom")
	main_ingredients = get_ingredient_names_with_tag("main")
	top_ingredients = get_ingredient_names_with_tag("top")
	bottom_burger_ingredients = get_ingredient_names_with_tag("bottom_burger")
	mid_burger_ingredients = get_ingredient_names_with_tag("mid_burger")
	top_burger_ingredients = get_ingredient_names_with_tag("top_burger")
	soup_base_ingredients = get_ingredient_names_with_tag("soup_base")
	soup_top_ingredients = get_ingredient_names_with_tag("soup_top")

	for desc in ingredient_descs:
		var png_name = "res://assets/food/" + desc.name + ".png"
		desc.png = load(png_name)
		assert(desc.png != null)
		
func get_ingredient_count():
	return ingredient_descs.size()

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

func get_random_ingredient_with_tag(tag):
	var ingredients_with_tag = get_ingredient_names_with_tag(tag)
	assert(ingredients_with_tag != null)
	if ingredients_with_tag.empty():
		return ""
	else:
		return ingredients_with_tag[randi() % ingredients_with_tag.size()]
		
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

func is_soup_base_ingredient(name):
	assert(is_ingredient(name))
	return soup_base_ingredients.has(name)

func is_soup_top_ingredient(name):
	assert(is_ingredient(name))
	return soup_top_ingredients.has(name)

func _check_unused_food_sprites():
	var dir = Directory.new()
	dir.open("res://assets/food/")
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if (file == ""):
			break
		if ((file == ".") or (file == "..")):
			continue
		if file.get_extension() != "png":
			continue
		var ingredient_name = file.get_basename()
		if (ingredient_name != "bowl") and (ingredient_name != "bowl_back") and (ingredient_name != "bowl_front") and (ingredient_name != "plate"):
			if not is_ingredient(ingredient_name):
				print("INFO: ", file, " doesn't have a matching ingredient")

	dir.list_dir_end()
	
func _check_ingredient_metadata():
	var ingredient_count = get_ingredient_count()
	for i in range(ingredient_count):
		var name = ingredient_names[i]
		assert(is_ingredient(name))
		assert(is_bottom_ingredient(name) or is_main_ingredient(name) or is_top_ingredient(name) or
			is_bottom_burger_ingredient(name) or is_mid_burger_ingredient(name) or is_top_burger_ingredient(name)
			or is_soup_base_ingredient(name) or is_soup_top_ingredient(name))
		var png_name = "res://assets/food/" + name + ".png"
		assert(load(png_name) != null)
		
	for desc in ingredient_descs:
		for tag in desc.tags:
			assert(tag_set.has(tag))
			
	for kw in plain_keywords:
		if not plain_keywords_synonyms.has(kw):
			print("WARNING: Synonyms were not declared for ", kw)
	for kw in plain_keywords_synonyms:
		if not plain_keywords.has(kw):
			print("WARNING: Synonyms are declared for ", kw, " though the ingredient is not declared")


	for desc in ingredient_descs:
		
		var count = desc.plain_keywords_fr.size()
		assert(count >= 2)
		
	_check_unused_food_sprites()
