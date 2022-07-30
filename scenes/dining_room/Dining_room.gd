extends Node

var waiter_scene = preload("res://scenes/dining_room/Waiter.tscn")

var waiter

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("cheffe_dish_sent", self, "_on_CheffeDish_Sent")
	waiter = waiter_scene.instance()
	add_child(waiter)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_CheffeDish_Sent(dish):
	print("cheffe dish ", dish)
