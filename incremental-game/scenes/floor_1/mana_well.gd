extends Node2D

var locked : bool = true

func check_unlock():
	if locked:
		$Sprite2D.material = null
