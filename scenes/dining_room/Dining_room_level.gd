extends Node

const Patron = preload("res://scenes/dining_room/Patron.tscn")

onready var tray = $Tray
onready var layout = $Layout
onready var dining_room = $DiningRoom
onready var waiter = $Layout/Waiter
onready var tables_nodes = $Layout/Tables
onready var patrons = $Patrons
onready var spawn_timer = $SpawnTimer

var tables = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("cheffe_dish_sent", self, "_on_CheffeDish_Sent")
	
	dining_room.connect("close_command_popup", self, "on_close_command_popup")
	dining_room.tray = tray
	
	for table_node in tables_nodes.get_children():
		if table_node.is_in_group("Tables"):
			tables.append(table_node)

	spawn_patron()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn_patron():
	var found_table_idx = -1
	var table
	for table_idx in len(tables):
		table = tables[table_idx]
		if len(table.patrons_around) == 0:
			found_table_idx = table_idx
			break
	if found_table_idx == -1:
		return
	var patron_dummy = Patron.instance()
	patrons.add_child(patron_dummy)
	table.patrons_around.append(patron_dummy)
	
	patron_dummy.connect("patron_clicked", self, "_on_Patron_clicked")
	patron_dummy.level_avatar.position.x = 546
	patron_dummy.level_avatar.position.y = 130
	patron_dummy.connect("patron_leaves", self, "_on_patron_leaves")
	# TODO: set the command_avatar.position positions correctly relative to the table as given in patron_dummy.destination
	patron_dummy.destination = table.position + Vector2(32, -55)
	patron_dummy.sitting_at_table = table
	patron_dummy.command_avatar.position.x = 960
	patron_dummy.command_avatar.position.y = 250
	
	patron_dummy.init()
	_refresh_layout_visible()

func _on_CheffeDish_Sent(dish):
	print("cheffe sends dish ", dish)
	tray.add_dish(dish)

func _refresh_layout_visible():
	_set_layout_visible(layout.visible)

func _set_layout_visible(set_visible):
	layout.visible = set_visible
	# TODO: we may also need to enable/disable controls eg pickable_inputs
	var patron_level_visible = set_visible
	var patron_command_visible
	for table in tables:
		patron_command_visible = false
		if (not set_visible):
			if (table.position.distance_to(waiter.position) < 80):
				patron_command_visible = true
		table.taking_commands = patron_command_visible
		for patron in table.patrons_around:
			patron.set_avatars_visible(patron_level_visible)
	
func _on_Patron_clicked(patron):
	if (patron.get_node("LevelAvatar").global_position.distance_to(waiter.position) < 80) and (dining_room.state == dining_room.State.NOT_VISIBLE):
		dining_room.pop_up([patron])
		_set_layout_visible(false)
	if dining_room.state == dining_room.State.VISIBLE:
		match patron.state:
			patron.State.WAITING_TO_ORDER:
				patron.set_state(patron.State.ORDERING)
				patron.set_state(patron.State.WAITING_TO_EAT)
			patron.State.WAITING_TO_EAT:
				if tray.selected_dish != null:
					var dish = tray.selected_dish
					tray.remove_dish(dish)
					patron.serve_dish(dish)
				else:
					patron.toggle_wanted_dish()
			patron.State.SHOW_DISH_SCORE:
				patron.hide_dish_score()
				patron.set_state(patron.State.LEAVING)

func _on_patron_leaves(patron):
	patron.sitting_at_table.patrons_around.erase(patron)
	# TODO: score ?

func on_close_command_popup():
	assert(dining_room.state == dining_room.State.VISIBLE)
	dining_room.pop_down()
	_set_layout_visible(true)

func _on_SpawnTimer_timeout():
	spawn_patron()
