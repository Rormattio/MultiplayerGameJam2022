extends Node2D

signal dish_clicked(ReceivedDish)

var state
var dish

enum State {
	UNSERVED,
	SELECTED,
	SERVED,
}

func _ready():
	state = State.UNSERVED

	$RootForOffset/Background.connect("gui_input", self, "_on_input_received")

func build(a_dish):
	self.dish = a_dish
	for ingredient_name in a_dish:
		if ingredient_name != "":
			add_ingredient(ingredient_name)

func add_ingredient(ingredient_name):
	assert(ingredient_name != "")
	var texture = load("res://assets/food/" + ingredient_name + ".png")
	var sprite = Sprite.new()
	sprite.texture = texture
	$RootForOffset.add_child(sprite)

func set_selected(a_selected: bool):
	state = State.SELECTED if a_selected else State.UNSERVED
	$RootForOffset.position.y = 30 if (state == State.SELECTED) else 0

func _on_input_received(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if state == State.SERVED:
			return
		emit_signal("dish_clicked", self)
