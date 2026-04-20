extends Node2D

var locked : bool = true

func check_unlock(value):
	if value.isGreaterThanOrEqualTo(10) and locked :
		$Sprite2D.material.shader = null
		locked = false


func _on_button_mouse_entered() -> void:
	if $Sprite2D.material.shader == null:
		var shader : Shader = load("res://shaders/outline.gdshader")
		$Sprite2D.material.shader = shader


func _on_button_mouse_exited() -> void:
	if !locked and $Sprite2D.material.shader != null:
		$Sprite2D.material.shader = null
