extends Node2D

const Dish = preload("res://Dish.gd")
const DishRenderer = preload("res://DishRenderer.gd")

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

func build(a_dish : Array):
	# TODO : The container type isn't passed :0
	var container_type = Dish.ContainerType.PLATE
	
	self.dish = Dish.new()
	var can_make_a_dish = self.dish.make_from_linear_ingredients(container_type, a_dish)
	assert(can_make_a_dish) 
	assert(self.dish.is_valid())

	var new_dish_sprite = DishRenderer.render_dish(self.dish)
	new_dish_sprite.position = Vector2(0, 0)
	new_dish_sprite.global_scale = Vector2(1, 1)
	
	$RootForOffset.add_child(new_dish_sprite)


func set_selected(a_selected: bool):
	state = State.SELECTED if a_selected else State.UNSERVED
	$RootForOffset.position.y = 30 if (state == State.SELECTED) else 0

func _on_input_received(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if state == State.SERVED:
			return
		emit_signal("dish_clicked", self)
