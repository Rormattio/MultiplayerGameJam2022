extends Node

func _ready():
	pass

func play(sfx):
	match sfx:
		Global.Sfx.SPLOTCH:
			$splotch.pitch_scale = rand_range(0.9, 1.1)
			$splotch.play()
		Global.Sfx.POP:
			$pop.pitch_scale = rand_range(0.9, 1.1)
			$pop.play()
		Global.Sfx.TENTACLE:
			$tentacle.pitch_scale = rand_range(0.9, 1.1)
			$tentacle.play()
		Global.Sfx.FFFT:
			$ffft.pitch_scale = rand_range(0.9, 1.1)
			$ffft.play()
		Global.Sfx.SHHOO:
			$shhoo.pitch_scale = rand_range(0.9, 1.1)
			$shhoo.play()
		Global.Sfx.CLICK:
			$click.play()
		Global.Sfx.SCHBOING:
			$shhoo.pitch_scale = rand_range(0.9, 1.1)
			$schboing.play()
		_: assert(false)
