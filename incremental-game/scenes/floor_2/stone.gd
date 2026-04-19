extends Node2D

var click_value_base = Big.new(1)
var click_value_mult = Big.new(1)

func _on_button_pressed() -> void:
	var final_value : Big = click_value_base.multiply(click_value_mult)
	gain_rune.emit(final_value, "stone")

signal gain_rune(value, src)
