extends Node2D

const red_hint_sprite = preload("res://assets/misc/red_hint.png")
const green_hint_sprite = preload("res://assets/misc/green_hint.png")
const orange_hint_sprite = preload("res://assets/misc/orange_hint.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func render(ingredient_diffs, dish_score_value):
	$Label.text = "+"+str(dish_score_value)+"$!"
	show()
	for idx in range(4):
		var sprite = get_node("Feedbacks/feedback_" + str(idx))
		match ingredient_diffs[idx]:
			0:
				sprite.texture = red_hint_sprite
			1:
				sprite.texture = orange_hint_sprite
			2:
				sprite.texture = green_hint_sprite
			_:
				assert(false)
