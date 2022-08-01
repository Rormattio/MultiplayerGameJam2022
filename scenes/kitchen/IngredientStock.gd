extends Node

onready var button = $Button

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
