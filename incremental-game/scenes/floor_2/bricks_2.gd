extends Control

var locked = true

func unlock_floor():
	if locked:
		self.material.shader = null
		locked = false
