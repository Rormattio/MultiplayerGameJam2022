extends Node

onready var button = $Button
onready var clues = $Clues

var clue_to_score = {}

signal ingredient_dish_set(ingredient_name)

var ingredient_name
var enabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
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

func score_feedback(clues : Array, score):
	print("In ingredient_stock=", ingredient_name, ", got score =", score, " for clues ", clues)
	# TODO

func _on_Button_focus_entered():
	if clues.get_child_count() > 0:
		clues.visible = true

func _on_Button_focus_exited():
	clues.visible = false
