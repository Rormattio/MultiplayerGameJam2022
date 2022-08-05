extends Node

const Patron = preload("res://scenes/dining_room/Patron.tscn")

onready var tray = $Layout/Tray
onready var layout = $Layout
onready var dining_room = $DiningRoom
onready var waiter = $Layout/Waiter
onready var tables_nodes = $Layout/Tables
onready var paths_to_tables = $Layout/Paths
onready var patrons = $Patrons
onready var spawn_timer = $SpawnTimer
onready var carrying_dish_node = $CarryingDish
onready var audio_sfx = $AudioSfx

var TRIGGER_COMMAND_AT_X_FROM_TABLE

var next_patron_index = 0
var tables = []

# Called when the node enters the scene tree for the first time.
func _ready():
	dining_room.connect("close_command_popup", self, "on_close_command_popup")
	dining_room.tray = tray

	if Global.DEBUG:
		TRIGGER_COMMAND_AT_X_FROM_TABLE = 2000
	else:
		TRIGGER_COMMAND_AT_X_FROM_TABLE = 160


	var used_paths = []
	for table_node in tables_nodes.get_children():
		assert(table_node.is_in_group("Tables"))
		tables.append(table_node)
		var found = false
		for path_node in paths_to_tables.get_children():
			var curve = path_node.get_curve()
			if table_node.position.distance_to(curve.get_point_position(curve.get_point_count()-1)) < 100:
				var path_follow = path_node.get_node("PathFollow2D")
				table_node.path_from_entrance = path_follow
				found = true
				assert(not (path_follow in used_paths))
				used_paths.append(path_follow)
				break
		assert(found)

	tray.waiter = waiter
	tray.dining_room_level = self

	spawn_patron()

	audio_sfx.play_ambience()

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
	patron_dummy.patron_index = next_patron_index
	next_patron_index += 1
	patrons.add_child(patron_dummy)
	table.patrons_around.append(patron_dummy)

	patron_dummy.command_avatar.connect("patron_avatar_command_clicked", self, "_on_patron_avatar_command_clicked")
	patron_dummy.level_avatar.connect("patron_avatar_level_clicked", self, "_on_patron_avatar_level_clicked")
	patron_dummy.level_avatar.position.x = 546
	patron_dummy.level_avatar.position.y = 130
	patron_dummy.connect("patron_leaves", self, "_on_patron_leaves")
	# TODO: set the command_avatar.position positions correctly relative to the table as given in patron_dummy.destination
	patron_dummy.destination = table.position + Vector2(32, -55)
	patron_dummy.sitting_at_table = table
	patron_dummy.command_avatar.position.x = 960
	patron_dummy.command_avatar.position.y = 250
	patron_dummy.path_to_follow = table.path_from_entrance

	patron_dummy.init()
	_refresh_layout_visible()

func set_carrying_received_dish(received_dish):
	if received_dish == null:
		assert(carrying_dish_node.get_child_count() == 1)
		var carried_dish = carrying_dish_node.get_child(0)
		carrying_dish_node.remove_child(carried_dish)
	else:
		assert(carrying_dish_node.get_child_count() == 0)
		carrying_dish_node.add_child(received_dish)
		received_dish.position = Vector2(0, 0)
		received_dish.set_state(received_dish.State.CARRIED)

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
			assert(dining_room.patrons.size() > 0)
			if dining_room.patrons[0] in table.patrons_around:
				patron_command_visible = true
		table.taking_commands = patron_command_visible
	for patron in patrons.get_children():
		patron.set_avatars_visible(patron_level_visible)

func _on_patron_avatar_level_clicked(patron):
	assert(dining_room.state == dining_room.State.NOT_VISIBLE)
	if (patron.sitting_at_table.position.distance_to(waiter.position) < TRIGGER_COMMAND_AT_X_FROM_TABLE):
		dining_room.pop_up([patron])
		_set_layout_visible(false)

func _on_patron_avatar_command_clicked(patron):
	assert(dining_room.state == dining_room.State.VISIBLE)
	match patron.state:
		patron.State.WAITING_TO_ORDER:
			patron.set_state(patron.State.ORDERING)
			patron.set_state(patron.State.WAITING_TO_EAT)
		patron.State.WAITING_TO_EAT:
			if carrying_dish_node.get_child_count() > 0:
				assert(carrying_dish_node.get_child_count() == 1)
				var dish = carrying_dish_node.get_child(0)
				set_carrying_received_dish(null)
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

func _on_Jukebox_button_up():
	audio_sfx.toggle_music()
