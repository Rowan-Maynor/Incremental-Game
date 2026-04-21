extends Control

var locked = true
var unlock_goal : Big = Big.new(1, 1)

func check_unlock(value):
	if not locked:
		return
	
	if value.isGreaterThanOrEqualTo(unlock_goal) and locked :
		self.material.shader = null
		locked = false
		$NinePatchRect.visible = false
	
	elif value.isGreaterThan(0) and locked:
		var percentage : Big = value.divide(unlock_goal)
		$NinePatchRect/ProgressBar.value = float(percentage.toString()) * 100
		if not $NinePatchRect.visible:
			$NinePatchRect.visible = true
