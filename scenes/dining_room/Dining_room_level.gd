extends Node

onready var tray = $Tray
onready var layout = $Layout
onready var dining_room = $DiningRoom
onready var waiter = $Layout/Waiter

onready var patron_dummy = $Layout/Patron # TODO; these should be spawned at runtime

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("cheffe_dish_sent", self, "_on_CheffeDish_Sent")
	
	dining_room.connect("close_command_popup", self, "on_close_command_popup")
	dining_room.tray = tray

	patron_dummy.connect("patron_clicked", self, "_on_Patron_clicked")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_CheffeDish_Sent(dish):
	print("cheffe sends dish ", dish)
	tray.add_dish(dish)

func _set_layout_visible(_visible):
	layout.visible = _visible
	# TODO: we may also need to enable/disable controls
	
func _on_Patron_clicked(patron):
	match patron.state:
		patron.State.WAITING_TO_ORDER:
			if (patron.position.distance_to(waiter.position) < 50) and (dining_room.state == dining_room.State.NOT_VISIBLE):
				dining_room.pop_up([patron])
				_set_layout_visible(false)
		patron.State.ORDERING:
			if tray.selected_dish != null:
				var dish = tray.selected_dish
				tray.remove_dish(dish)
				patron.serve_dish(dish)
			else:
				patron.toggle_wanted_dish()
		patron.State.SHOW_DISH_SCORE:
			patron.hide_dish_score()
			patron.set_state(patron.State.LEAVING)

func on_close_command_popup():
	assert(dining_room.state == dining_room.State.VISIBLE)
	dining_room.pop_down()
	_set_layout_visible(true)
