extends Control

var well_base_cost : Big = Big.new(1, 1)
var well_base_cost_inc_rate : Big = Big.new(1, 0)
var well_base_value : Big = Big.new(1, 0)
@onready var well_base_label: Label = $PanelContainer/MarginContainer/VBoxContainer/well_base/MarginContainer/HBoxContainer/HBoxContainer2/cost
@onready var well_base_button: Button = $PanelContainer/MarginContainer/VBoxContainer/well_base

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_position = get_viewport().get_mouse_position()
			if not self.get_global_rect().has_point(mouse_position):
				close_panel()

func _ready() -> void:
	update_well_base_label()

func check_well_base_cost(value):
	if well_base_cost.isGreaterThan(value):
		well_base_button.disabled = true
	else:
		well_base_button.disabled = false

func update_well_base_label():
	well_base_label.text = well_base_cost.toAA()

func _on_well_base_pressed() -> void:
	spend_mana.emit(well_base_cost)
	well_base_increase.emit(well_base_value)
	well_base_cost.multiplyEquals(well_base_cost_inc_rate)
	update_well_base_label()

func close_panel():
	self.visible = false

signal well_base_increase(value)
signal spend_mana(value)
