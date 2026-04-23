extends Node2D

var click_value_base = Big.new(1)
var click_value_mult = Big.new(1)
var locked : bool = false

signal gain_mana(value, src)

func increase_base(value):
	click_value_base.plusEquals(value)

func increase_mult(value):
	click_value_mult.plusEquals(value)

func unlock_auto_click(_value):
	$Timer.start()

func increase_auto_rate(value):
	$Timer.wait_time -= value

func _on_button_pressed() -> void:
	var final_value : Big = click_value_base.multiply(click_value_mult)
	gain_mana.emit(final_value, "orb")

func _on_button_mouse_entered() -> void:
	if $Sprite2D.material.shader == null:
		var shader : Shader = load("res://shaders/outline.gdshader")
		$Sprite2D.material.shader = shader

func _on_button_mouse_exited() -> void:
	if !locked and $Sprite2D.material.shader != null:
		$Sprite2D.material.shader = null

func _on_timer_timeout() -> void:
	var final_value : Big = click_value_base.multiply(click_value_mult)
	gain_mana.emit(final_value, "orb_auto")
