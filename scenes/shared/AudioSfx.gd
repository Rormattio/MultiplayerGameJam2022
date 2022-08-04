extends Node

var available_host_fs_musics = []

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
	
func _ready():
	##play_host_music("D:/perso/zik/OI! - PUNK - HXC - METAL/BULLDOZER - Bulldozer/06 - Il était une tranche de foie dans l'ouest.ogg")
	##play_host_music("D:/perso/zik/PSYCHO - ROCKAB - SWING/QUAKES - Psyops/06 beer & cigarettes.mp3")
	pass

func play(sfx):
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
		Ingredients.Sfx.SCHBOING:
			$shhoo.pitch_scale = rand_range(0.9, 1.1)
			$schboing.play()
		_: assert(false)
