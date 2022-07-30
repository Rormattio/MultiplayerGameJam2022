extends Node2D

signal dish_clicked(ReceivedDish)

var selected

func _ready():
	selected = false

	$RootForOffset/Background.connect("gui_input", self, "_on_input_received")
	pass

func add_ingredient(ingredient_name):
	var texture = load("res://assets/food/" + ingredient_name + ".png")
	var sprite = Sprite.new()
	sprite.texture = texture
	$RootForOffset.add_child(sprite)

func set_selected(a_selected: bool):
	selected = a_selected
	$RootForOffset.position.y = 30 if selected else 0

func _on_input_received(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("dish_clicked", self)
