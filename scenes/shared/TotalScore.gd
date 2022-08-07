extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

func render(score_value, play):
	$Label.text = str(score_value)+"$"
	if play:
		#Global.logger("play cashings sound")
		$cashings.play()
	show()
