extends Node2D

var locked : bool = true
var rock_well : bool = false
var unlock_goal : Big = Big.new(5, 2)
var well_base : Big = Big.new(5, 1)
var well_mult : Big = Big.new(1, 0)

signal mana_well_unlocked()
signal open_panel()
signal gain_mana(value, src)
signal gain_rune(value, src)

func check_unlock(_type, value):
	if not locked:
		return
	
	if value.isGreaterThanOrEqualTo(unlock_goal) and locked :
		$Sprite2D.material.shader = null
		locked = false
		$Button.disabled = false
		emit_signal("mana_well_unlocked")
		$NinePatchRect.visible = false
		$Timer.start()
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

func increase_base(value):
	well_base.plusEquals(value)

func increase_mult(value):
	well_mult.plusEquals(value)

func increase_rate(value):
	if $Timer.wait_time > 1.0:
		$Timer.wait_time -= value
	else:
		print("Exceeded maximum rate")

func unlock_rock_well(value):
	rock_well = value

func _on_timer_timeout() -> void:
	var final_value : Big = well_base.multiply(well_mult)
	gain_mana.emit(final_value, "well")
	if rock_well:
		var final_rune : Big = final_value.divide(Big.new(1, 3))
		var one : Big = Big.new(1, 0)
		if final_rune.isLessThan(one):
			gain_rune.emit(one, "well")
		else:
			gain_rune.emit(final_rune, "well")
	$Sprite2D.play("pulse")


func _on_sprite_2d_animation_finished() -> void:
	if $Sprite2D.animation == "pulse":
		$Sprite2D.play("idle")
