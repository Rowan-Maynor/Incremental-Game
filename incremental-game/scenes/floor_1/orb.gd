extends Node2D

var click_value_base = Big.new(1)
var click_value_mult = Big.new(1)

func _on_button_pressed() -> void:
	var final_value : Big = click_value_base.multiply(click_value_mult)
	gain_mana.emit(final_value, "orb")

signal gain_mana(value, src)
