extends Control

var locked = true
var unlock_goal : Big = Big.new(1, 4)

signal unlock_stone()

func check_unlock(_type, value):
	if not locked:
		return
	
	if value.isGreaterThanOrEqualTo(unlock_goal) and locked :
		self.material.shader = null
		locked = false
		$NinePatchRect.visible = false
		unlock_stone.emit()
	
	elif value.isGreaterThan(0) and locked:
		var percentage : Big = value.divide(unlock_goal)
		$NinePatchRect/ProgressBar.value = float(percentage.toString()) * 100
		if not $NinePatchRect.visible:
			$NinePatchRect.visible = true
