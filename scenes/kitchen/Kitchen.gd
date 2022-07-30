extends Node

var cheffe_scene = preload("res://scenes/kitchen/Cheffe.tscn")

var cheffe

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("waiter_command_sent", self, "_on_WaiterCommand_Sent")
	cheffe = cheffe_scene.instance()
	add_child(cheffe)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_WaiterCommand_Sent(dish):
	print("waiter command ", dish)
