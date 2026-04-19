extends Node2D

var locked : bool = true

func check_unlock(value):
	if value.isGreaterThanOrEqualTo(10) and locked :
		$Sprite2D.material = null
