extends Node

onready var button = $Button
onready var clues_overlay = $Overlay
onready var clues = $Overlay/Clues
var clue_to_score = {}

signal ingredient_dish_set(ingredient_name)

var ingredient_name
var enabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
#	clues.append_bbcode("[color=red]text[/color]\n[color=yellow]text2[/color]")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Button_pressed():
	emit_signal("ingredient_dish_set", ingredient_name)

func set_enabled(a_enabled: bool):
	enabled = a_enabled
	$Button.disabled = not a_enabled
	$Sprite.modulate = Color(1,1,1,1) if a_enabled else Color(0,0,0,0.1)

func score_feedback(command_clues : Array, score):
	print("In ingredient_stock=", ingredient_name, ", got score =", score, " for clues ", command_clues)
	for clue in command_clues:
		if clue in clue_to_score:
			clue_to_score[clue] = int(round((clue_to_score[clue] + score)/2))
		else:
			clue_to_score[clue] = score
	clues.clear()
	for clue in clue_to_score:
		var clue_score = clue_to_score[clue]
		var color
		if clue_score < 4:
			color = "red"
		elif clue_score < 7:
			color = "yellow"
		else:
			color = "green"
		clues.append_bbcode("[color=" + color + "]" + clue + "[/color]\n")

func _on_Button_mouse_entered():
	return # Decided that we do not want clues presented in this way for Cheffe. Instead we made the history.
	if len(clue_to_score) > 0:
		clues_overlay.visible = true

func _on_Button_mouse_exited():
	clues_overlay.visible = false
