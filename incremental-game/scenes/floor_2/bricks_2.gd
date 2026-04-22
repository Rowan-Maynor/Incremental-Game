extends Control

var locked = true

func unlock_floor_2():
	if not locked:
		return
	else:
		self.material.shader = null
		locked = false
