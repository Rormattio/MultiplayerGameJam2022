extends Node

func _ready():
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
