extends Control

var unlock_goal : Big = Big.new(1, 4)

signal unlock_stone()
signal unlock_floor_2()

func check_unlock(_type, value):
	if value.isGreaterThanOrEqualTo(unlock_goal):
		$NinePatchRect.visible = false
		unlock_stone.emit()
		unlock_floor_2.emit()
	
	elif value.isGreaterThan(0):
		var percentage : Big = value.divide(unlock_goal)
		$NinePatchRect/ProgressBar.value = float(percentage.toString()) * 100
		if not $NinePatchRect.visible:
			$NinePatchRect.visible = true
