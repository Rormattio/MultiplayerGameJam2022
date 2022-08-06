extends Node

const PatronScene = preload("res://scenes/dining_room/Patron.tscn")
const DishRenderer = preload("res://DishRenderer.gd")

onready var tray = $Tray
onready var layout = $Layout
onready var dining_room = $DiningRoom
onready var waiter = $Layout/Waiter
onready var tables_nodes = $Layout/Tables
onready var paths_to_tables = $Layout/Paths
onready var patrons = $Patrons
onready var spawn_timer = $SpawnTimer
onready var carrying_dish_node = $CarryingDish
onready var audio_sfx = $AudioSfx
onready var door = $door
onready var door_close_timer = $door/CloseTimer
onready var score_box = $Score

var TRIGGER_COMMAND_AT_X_FROM_TABLE

var score_value

var tables = []
var patron_random_pool = []

# Called when the node enters the scene tree for the first time.
func _ready():
	score_value = 0
	dining_room.connect("close_command_popup", self, "on_close_command_popup")
	dining_room.connect("serve_dish_pressed", self, "_on_serve_dish")

	dining_room.tray = tray

	door_close_timer.connect("timeout", self, "close_door")

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
	score_box.render(Global.get_total_score())

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

	var patron_dummy = PatronScene.instance()

	if patron_random_pool.size() == 0:
		for i in range(patron_dummy.PATRON_SPRITE_NAMES.size()):
			patron_random_pool.append(i)
		patron_random_pool.shuffle()
	var random_patron_index = patron_random_pool.pop_back()
	patron_dummy.patron_index = random_patron_index
	patrons.add_child(patron_dummy)
	table.patrons_around.append(patron_dummy)

	patron_dummy.command_avatar.connect("patron_avatar_command_clicked", self, "_on_patron_avatar_command_clicked")
	patron_dummy.level_avatar.connect("patron_avatar_level_clicked", self, "_on_patron_avatar_level_clicked")
	patron_dummy.level_avatar.position.x = -100
	patron_dummy.level_avatar.position.y = 100
	patron_dummy.connect("patron_leaves", self, "_on_patron_leaves")
	# TODO: set the command_avatar.position positions correctly relative to the table as given in patron_dummy.destination
	patron_dummy.destination = table.position + Vector2(32, -55)
	patron_dummy.sitting_at_table = table
	patron_dummy.command_avatar.position.x = 780
	patron_dummy.command_avatar.position.y = 300
	patron_dummy.path_to_follow = table.path_from_entrance
	patron_dummy.connect("patron_enters_room", self, "open_door")
	patron_dummy.connect("patron_exits_room", self, "open_door")
	patron_dummy.connect("patron_state_changed", self, "_on_patron_state_changed")

	patron_dummy.init()
	_refresh_layout_visible()

func set_carrying_received_dish(received_dish):
	if received_dish == null:
		assert(carrying_dish_node.get_child_count() == 1)
		var carried_dish = carrying_dish_node.get_child(0)
		carrying_dish_node.remove_child(carried_dish)
		# remove from dining_room
		var rendered_dish_1 = $DiningRoom/DialogueGiveDish/DishPos.get_child(0)
		$DiningRoom/DialogueGiveDish/DishPos.remove_child(rendered_dish_1)
	else:
		assert(carrying_dish_node.get_child_count() == 0)
		carrying_dish_node.add_child(received_dish)
		received_dish.position = Vector2(0, 0)
		received_dish.set_state(received_dish.State.CARRIED)
		# create another copy for dining_room
		var rendered_dish_1 = DishRenderer.render_dish(received_dish.dish)
		$DiningRoom/DialogueGiveDish/DishPos.add_child(rendered_dish_1)

func _refresh_layout_visible():
	_set_layout_visible(dining_room.state == dining_room.State.NOT_VISIBLE)

func _set_layout_visible(set_visible):
	layout.visible = set_visible
	# TODO: we may also need to enable/disable controls eg pickable_inputs
	var patron_level_visible = set_visible
	var patron_command_visible
	for table in tables:
		table.is_popped_up = table == dining_room.table
	if not set_visible:
		assert(dining_room.table.patrons_around.size() > 0) # how did we get here if there was no patron to click on ?!
	if not set_visible:
		dining_room.update_waiter_actions()
	for patron in patrons.get_children():
		patron.set_avatars_visible(patron_level_visible)

func _on_patron_avatar_level_clicked(patron):
	assert(dining_room.state == dining_room.State.NOT_VISIBLE)
	if (patron.sitting_at_table.position.distance_to(waiter.position) < TRIGGER_COMMAND_AT_X_FROM_TABLE):
		dining_room.pop_up(patron.sitting_at_table)
		_set_layout_visible(false)

func _on_patron_avatar_command_clicked(patron):
	assert(dining_room.state == dining_room.State.VISIBLE)
	match patron.state:
		patron.State.WAITING_TO_EAT:
			patron.toggle_wanted_dish()

func _on_serve_dish(patron):
	assert(carrying_dish_node.get_child_count() == 1)
	var dish = carrying_dish_node.get_child(0)
	set_carrying_received_dish(null)
	patron.serve_dish(dish)

func _on_patron_leaves(patron):
	patron.sitting_at_table.patrons_around.erase(patron)
	# TODO: score the score ?

func on_close_command_popup():
	assert(dining_room.state == dining_room.State.VISIBLE)
	dining_room.pop_down()
	_set_layout_visible(true)

func _on_SpawnTimer_timeout():
	spawn_patron()

func _on_Jukebox_button_up():
	audio_sfx.toggle_music()

func open_door():
	door.hide()
	door_close_timer.start()

func close_door():
	door.show()

func _on_patron_state_changed(patron):
	if dining_room.state == dining_room.State.VISIBLE:
		dining_room.update_waiter_actions()
	
	match patron.state:
		patron.State.ENTERING:
			if patron.sprite_name == "bertmo":
				$AudioSfx.play_voice(patron.Sound.HELLO_ELMO)
			else:
				$AudioSfx.play_voice(patron.Sound.OHAYO)
		patron.State.LEAVING_BEHIND_WINDOW:
			if patron.sprite_name == "bertmo":
				$AudioSfx.play_voice(patron.Sound.BYE_ELMO)
			else:
				$AudioSfx.play_voice(patron.Sound.TCHAO)
