extends Node

enum Sfx {
	SPLOTCH,
	POP,
	TENTACLE,
	FFFT,
	SHHOO,
	CLICK,
	SCHBOING,
	WHOOO,
	TRASH
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
	IngredientDesc.new("black_forest_hole", ["main"],
		["black", "space", "fruit"], [],
		null),
	IngredientDesc.new("blue_banana", ["main"],
		["blue", "vegetal", "fruit"], [],
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
	IngredientDesc.new("crab", ["mid_burger", "main"],
		["creature", "claws"], [],
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
		["creature", "skewer"], [],
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
		["planet", "black", "round", "space"], [],
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
		["smoke", "kaki", "gas"], [],
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
]

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

func get_ingredient_desc(name):
	for desc in Ingredients.ingredient_descs:
		if desc.name == name:
			return desc
	return null

func ingredient_has_tag(name, flag):
	return get_ingredient_desc(name).has_tag(flag)
