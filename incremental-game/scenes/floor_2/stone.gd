extends Node2D

var click_value_base = Big.new(1, 0)
var click_value_mult = Big.new(1, 0)
var swing_power : float = 1.0
var locked : bool = true
var auto_click_unlocked = false

signal gain_rune(value, src)
signal unlock_floor()
signal stone_unlocked()

func _on_button_pressed() -> void:
	if $NinePatchRect.visible == false:
		$NinePatchRect.visible = true
	$NinePatchRect/ProgressBar.value += swing_power
	check_progress()

func check_progress():
	if $NinePatchRect/ProgressBar.value == $NinePatchRect/ProgressBar.max_value:
		$NinePatchRect/ProgressBar.value = 0
		$NinePatchRect.visible = false
		var final_value : Big = click_value_base.multiply(click_value_mult)
		if auto_click_unlocked:
			gain_rune.emit(final_value, "stone_auto")
		else:
			gain_rune.emit(final_value, "stone")

func check_unlock():
	$Sprite2D.material.shader = null
	locked = false
	$Button.disabled = false
	unlock_floor.emit()
	stone_unlocked.emit()

func _on_button_mouse_entered() -> void:
	if $Sprite2D.material.shader == null:
		var shader : Shader = load("res://shaders/outline.gdshader")
		$Sprite2D.material.shader = shader


func _on_button_mouse_exited() -> void:
	if !locked and $Sprite2D.material.shader != null:
		$Sprite2D.material.shader = null

func increase_base(value):
	click_value_base.plusEquals(value)

func increase_swing_power(value):
	swing_power += value

func unlock_auto_click(_value):
	$Timer.start()
	auto_click_unlocked = true

func _on_timer_timeout() -> void:
	_on_button_pressed()
