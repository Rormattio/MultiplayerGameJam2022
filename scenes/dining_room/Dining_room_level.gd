extends Node

onready var tray = $Tray
onready var layout = $Layout
onready var dining_room = $DiningRoom
onready var waiter = $Layout/Waiter

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("cheffe_dish_sent", self, "_on_CheffeDish_Sent")
	
	dining_room.visible = false
	dining_room.tray = tray
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_CheffeDish_Sent(dish):
	print("cheffe sends dish ", dish)
	tray.add_dish(dish)
