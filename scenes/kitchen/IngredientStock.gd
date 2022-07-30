extends Node

onready var checkbox = $CheckBox

signal ingredient_dish_set(toggled, ingredient_name)

var ingredient_name

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_CheckBox_toggled(toggled):
	emit_signal("ingredient_dish_set", toggled, ingredient_name)
