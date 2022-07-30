extends KinematicBody2D

onready var send_dish = $SendDish
onready var dish_input = $DishInput

func _ready():
	send_dish.connect("pressed", self, "_on_ButtonPressed")

func _process(delta: float) -> void:
	pass

func _on_ButtonPressed():
	var dish = dish_input.text
	Global.cheffe_send_dish(dish)
