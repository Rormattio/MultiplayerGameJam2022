extends Node

# TODO refactor AudioSfx somehow, because right now it is instanciated in several scenes so sound data is being duplicated

var available_host_fs_musics = []
var ambiance_players = []
var jukebox

class PatronSounds:
	var hello_sound
	var nomnom_sound
	var bye_sound

enum PatronVoice { HELLO, NOMNOM, BYE}

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
		if nomnom_sound == null:
			nomnom_sound = load("res://assets/sfx/omnomnom.ogg")
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

func get_voice_stream_for_patron(patron : String, voice):
	match voice:
		PatronVoice.HELLO:
			return get_hello_stream_for_patron(patron)
		PatronVoice.Voice.NOMNOM:
			return get_nomnom_stream_for_patron(patron)
		PatronVoice.Voice.BYE:
			return get_bye_stream_for_patron(patron)
		_:
			assert(false)
			return null

func get_hello_stream_for_patron(patron : String):
	var sounds = patron_sounds[patron]
	if sounds == null:
		return null
	return sounds.hello_sound

func get_nomnom_stream_for_patron(patron : String):
	var sounds = patron_sounds[patron]
	if sounds == null:
		return null
	return sounds.nomnom_sound

func get_bye_stream_for_patron(patron : String):
	var sounds = patron_sounds[patron]
	if sounds == null:
		return null
	return sounds.bye_sound
	
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
	
	jukebox = Jukebox.init($RadioPlaceholder, $MusicPlaceholder)
	
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
		player.connect("finished", self, "_on_ambience_sound_finished")

func _on_ambience_sound_finished():
	for player in ambiance_players:
		if not player.playing:
			player.play()

func advance_jukebox_state():
	rpc("_advance_jukebox_state")

remotesync func _advance_jukebox_state():
	jukebox.advance_state()

class Jukebox:
	enum JukeboxState {
		OFF,
		RADIO,
		MUSICS,
	}

	var RADIO_SOUND_SEQ = [
		"0_salut",
		"1_jam",
		"radio_georgette",
		"2_meteo",
		"radio_georgette",
		"3_info_trafic",
		"radio_georgette",
		"Space_Jazz_radio_georgette",
		"4_nebulx",
		"radio_georgette",
		"5_crypto-burger",
		"radio_georgette",
		"Space_Jazz_radio_georgette",
	]
	var radio_sounds = {}
	var state = JukeboxState.OFF
	var radio_sound_index = -1
	var radio_ph
	var music_ph
	
	static func init(o_radio_ph, o_music_ph):
		var jukebox = Jukebox.new()
		jukebox._build_radio_sounds()
		
		jukebox.radio_ph = o_radio_ph
		jukebox.radio_ph.volume_db = - 20
		jukebox.radio_ph.connect("finished", jukebox, "_on_sound_finish")
		
		jukebox.music_ph = o_music_ph
		jukebox.music_ph.volume_db = - 20
		
		return jukebox

	func _build_radio_sounds():
		for sound_name in RADIO_SOUND_SEQ:
			if not (sound_name in radio_sounds):
				var sound = load("res://assets/sfx/radio/" + sound_name + ".ogg")
				assert(sound != null)
				radio_sounds[sound_name] = sound
				sound.set_loop(false)
	
	func advance_state():
		radio_sound_index = -1
		match state:
			JukeboxState.OFF:
				state = JukeboxState.RADIO
				advance_radio_state()
			JukeboxState.RADIO:
				radio_ph.stop()
				state = JukeboxState.MUSICS
				play_host_music("./assets/musics/Derp_Nugget.mp3")
			JukeboxState.MUSICS:
				state = JukeboxState.OFF
				music_ph.stop()
	
	func advance_radio_state():
		radio_sound_index = (radio_sound_index + 1)%len(RADIO_SOUND_SEQ)
		radio_ph.stream = radio_sounds[RADIO_SOUND_SEQ[radio_sound_index]]
		radio_ph.play()
	
	func _on_sound_finish():
		match state:
			JukeboxState.RADIO:
				advance_radio_state()
		
	func play_host_music(path):
		music_ph.stop()
		var file = File.new()
		var err = file.open(path, File.READ)
		if err == OK:
			var data = file.get_buffer(file.get_len())
			var extension = path.get_extension().to_lower()
			if extension == "ogg":
				var ogg = AudioStreamOGGVorbis.new()
				ogg.data = data
				music_ph.stream = ogg
			elif extension == "mp3":
				var mp3 = AudioStreamMP3.new()
				mp3.data = data
				music_ph.stream = mp3
			file.close()
			music_ph.play()
