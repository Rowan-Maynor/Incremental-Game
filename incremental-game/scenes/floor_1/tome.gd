extends Node2D

var locked : bool = true
var unlock_goal : Big = Big.new(1, 1)

signal tome_unlocked()
signal open_panel()

func check_unlock(value):
	if not locked:
		return
	
	if value.isGreaterThanOrEqualTo(unlock_goal) and locked :
		$Sprite2D.material.shader = null
		locked = false
		$Button.disabled = false
		emit_signal("tome_unlocked")
		$NinePatchRect.visible = false
	elif value.isGreaterThan(0) and locked:
			var percentage : Big = value.divide(unlock_goal)
			$NinePatchRect/ProgressBar.value = float(percentage.toString()) * 100
			if not $NinePatchRect.visible:
				$NinePatchRect.visible = true

func _on_button_mouse_entered() -> void:
	if $Sprite2D.material.shader == null:
		var shader : Shader = load("res://shaders/outline.gdshader")
		$Sprite2D.material.shader = shader

func _on_button_mouse_exited() -> void:
	if !locked and $Sprite2D.material.shader != null:
		$Sprite2D.material.shader = null

func _on_button_pressed() -> void:
	open_panel.emit()
