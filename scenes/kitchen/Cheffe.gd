extends KinematicBody2D

func _ready():
	$SendDish.connect("pressed", self, "_on_ButtonPressed")

func _process(delta: float) -> void:
	pass

func _on_ButtonPressed():
	var dish = $DishInput.text
	Global.cheffe_send_dish(dish)
