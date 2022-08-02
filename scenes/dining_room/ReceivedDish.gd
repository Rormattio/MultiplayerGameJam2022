extends Node2D

const Dish = preload("res://Dish.gd")
const DishRenderer = preload("res://DishRenderer.gd")

signal dish_clicked(ReceivedDish)

var state
var dish
var dish_index_in_kitchen_counter

enum State {
	UNSERVED,
	CARRIED,
	SERVED,
}

func _ready():
	state = State.UNSERVED

	$RootForOffset/Background.connect("gui_input", self, "_on_input_received")

func build(a_dish : Array):
	self.dish = Dish.new()
	self.dish.deserialize(a_dish)
	assert(self.dish.is_valid())

	var new_dish_sprite = DishRenderer.render_dish(self.dish)
	new_dish_sprite.position = Vector2(0, 0)
	new_dish_sprite.global_scale = Vector2(1, 1)
	
	$RootForOffset.add_child(new_dish_sprite)

func _on_input_received(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if state == State.UNSERVED:
			emit_signal("dish_clicked", self)

func set_state(a_state):
	match a_state:
		State.UNSERVED:
			pass
		State.CARRIED:
			pass
		State.SERVED:
			pass
	state = a_state
