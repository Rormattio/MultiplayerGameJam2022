extends Node

# TODO refactor AudioSfx somehow, because right now it is instanciated in several scenes so sound data is being duplicated

var available_host_fs_musics = []
var ambiance_players = []
var proba_play_voice_sound = {}
var proba_play_voice_sound_decrease = 0.9

class PatronSounds:
	var hello_sound
	var nomnom_sound
	var bye_sound

var patron_sounds = {}

func _build_patron_sounds():
	var PATRON_NAMES = [
		"bertmo",
		"frog",
		"duck",
		"auronron",
		"fmdkdd",
		"fromage_chaud",
	]
	for patron in PATRON_NAMES:
		var sounds = PatronSounds.new()

		var hello_sound = load("res://assets/sfx/hello_" + patron + ".ogg")
		if hello_sound == null:
			hello_sound = load("res://assets/sfx/ohayo.ogg")
		if hello_sound != null:
			hello_sound.set_loop(false)
		sounds.hello_sound = hello_sound 

		var nomnom_sound = load("res://assets/sfx/nomnom_" + patron + ".ogg")
		if nomnom_sound != null:
			nomnom_sound.set_loop(false)
		sounds.nomnom_sound = nomnom_sound 

		var bye_sound = load("res://assets/sfx/bye_" + patron + ".ogg")
		if bye_sound == null:
			bye_sound = load("res://assets/sfx/tchao.ogg")
		if bye_sound != null:
			bye_sound.set_loop(false)
		sounds.bye_sound = bye_sound
		 
		patron_sounds[patron] = sounds

func get_hello_stream_for_patron(patron):
	var sounds = patron_sounds[patron]
	if sounds == null:
		return null
	return sounds.hello_sound

func get_nomnom_stream_for_patron(patron):
	var sounds = patron_sounds[patron]
	if sounds == null:
		return null
	return sounds.nomnom_sound

func get_bye_stream_for_patron(patron):
	var sounds = patron_sounds[patron]
	if sounds == null:
		return null
	return sounds.bye_sound
	
func play_host_music(path):
	$bg_music_player.stop()
	var file = File.new()
	var err = file.open(path, File.READ)
	if err == OK:
		var data = file.get_buffer(file.get_len())
		var extension = path.get_extension().to_lower()
		if extension == "ogg":
			var ogg = AudioStreamOGGVorbis.new()
			ogg.data = data
			$bg_music_player.stream = ogg
		elif extension == "mp3":
			var mp3 = AudioStreamMP3.new()
			mp3.data = data
			$bg_music_player.stream = mp3
		file.close()
		$bg_music_player.play()
		$bg_music_player.volume_db = - 20
	
func toggle_music():
	if $bg_music_player.playing:
		$bg_music_player.stop()
	else:
		play_host_music("./assets/musics/Derp_Nugget.mp3")
	
func _ready():
	##play_host_music("D:/perso/zik/OI! - PUNK - HXC - METAL/BULLDOZER - Bulldozer/06 - Il était une tranche de foie dans l'ouest.ogg")
	##play_host_music("D:/perso/zik/PSYCHO - ROCKAB - SWING/QUAKES - Psyops/06 beer & cigarettes.mp3")
	var ambiance_tracks = [
		"res://assets/sfx/ambiance/bruits_de_cuisine.wav"
	]
	for idx in range(4):
		ambiance_tracks.push_back("res://assets/sfx/ambiance/ambiance" + str(idx) + ".wav")
		
	for track in ambiance_tracks:
		var node = AudioStreamPlayer.new()
		var stream = load(track)
		node.stream = stream
		add_child(node)
		ambiance_players.append(node)

	_build_patron_sounds()
	
func play_ingredient(sfx):
	match sfx:
		Ingredients.Sfx.SPLOTCH:
			$splotch.pitch_scale = rand_range(0.9, 1.1)
			$splotch.play()
		Ingredients.Sfx.POP:
			$pop.pitch_scale = rand_range(0.9, 1.1)
			$pop.play()
		Ingredients.Sfx.TENTACLE:
			$tentacle.pitch_scale = rand_range(0.9, 1.1)
			$tentacle.play()
		Ingredients.Sfx.FFFT:
			$ffft.pitch_scale = rand_range(0.9, 1.1)
			$ffft.play()
		Ingredients.Sfx.SHHOO:
			$shhoo.pitch_scale = rand_range(0.9, 1.1)
			$shhoo.play()
		Ingredients.Sfx.CLICK:
			$click.play()
		Ingredients.Sfx.WHOOO:
			$whooo.pitch_scale = rand_range(0.9, 1.1)
			$whooo.play()
		Ingredients.Sfx.SCHBOING:
			$schboing.pitch_scale = rand_range(0.9, 1.1)
			$schboing.play()
		_: assert(false)

func play_ambience():
	for player in ambiance_players:
		player.play()
		player.volume_db = - 20
		player.connect("finished", self, "_on_sound_finished")

func _on_sound_finished():
	for player in ambiance_players:
		if not player.playing:
			player.play()
