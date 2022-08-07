extends Node2D

const Dish = preload("res://Dish.gd")
const DishRenderer = preload("res://DishRenderer.gd")
const Order = preload("res://scenes/shared/Order.gd")

signal dish_clicked(ReceivedDish)

var state
var dish
var dish_index_in_kitchen_counter
var order : Order

enum State {
	UNSERVED,
	CARRIED,
	SERVED,
}

func _ready():
	state = State.UNSERVED
	
	$RootForOffset/Button.connect("button_up", self, "_on_button_up")
	$RootForOffset/Background.modulate.a = 0

func build(a_dish : Array):
	self.dish = Dish.new()
	self.dish.deserialize(a_dish)
	assert(self.dish.is_valid())

	var new_dish_sprite = DishRenderer.render_dish(self.dish)
	new_dish_sprite.position = Vector2(0, 0)
	new_dish_sprite.global_scale = Vector2(1, 1)
	
	$RootForOffset.add_child(new_dish_sprite)

func _on_button_up():
	assert(state == State.UNSERVED)
	emit_signal("dish_clicked", self)

func set_state(a_state):
	match a_state:
		State.UNSERVED:
			$RootForOffset/Background.modulate.a = 0
			$RootForOffset/Button.visible = true
		State.CARRIED:
			$RootForOffset/Background.modulate.a = 255
			$RootForOffset/Button.visible = false
		State.SERVED:
			$RootForOffset/Background.modulate.a = 255
			$RootForOffset/Button.visible = false
	state = a_state
