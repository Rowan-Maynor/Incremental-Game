extends Node2D

var click_value_base = Big.new(1)
var click_value_mult = Big.new(1)
var locked : bool = true

func _on_button_pressed() -> void:
	var final_value : Big = click_value_base.multiply(click_value_mult)
	gain_rune.emit(final_value, "stone")

func check_unlock(value):
	if value.isGreaterThanOrEqualTo(10) and locked :
		$Sprite2D.material.shader = null
		locked = false
		unlock_floor.emit()
		stone_unlocked.emit()
		
		#remove the connection so im not calling excessive functions
		var connections = unlock_floor.get_connections()
		unlock_floor.disconnect(connections[0]["callable"])

func _on_button_mouse_entered() -> void:
	if $Sprite2D.material.shader == null:
		var shader : Shader = load("res://shaders/outline.gdshader")
		$Sprite2D.material.shader = shader


func _on_button_mouse_exited() -> void:
	if !locked and $Sprite2D.material.shader != null:
		$Sprite2D.material.shader = null

signal gain_rune(value, src)
signal unlock_floor()
signal stone_unlocked()
