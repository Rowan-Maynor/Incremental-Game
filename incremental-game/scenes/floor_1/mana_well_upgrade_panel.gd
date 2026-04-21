extends Control

#well base upgrade
var well_base_cost : Big = Big.new(1, 1)
var well_base_cost_inc_rate : Big = Big.new(1, 0)
var well_base_value : Big = Big.new(1, 0)

#well rate upgrade
var well_rate_max : int = 9
var well_rate_cost : Big = Big.new(1, 1)
var well_rate_cost_inc_rate : Big = Big.new(1, 0)
var well_rate_value : int = 1

#paths
@onready var well_base_label: Label = $PanelContainer/MarginContainer/VBoxContainer/well_base/MarginContainer/HBoxContainer/HBoxContainer2/cost
@onready var well_base_button: Button = $PanelContainer/MarginContainer/VBoxContainer/well_base
@onready var well_rate_label: Label = $PanelContainer/MarginContainer/VBoxContainer/well_rate/MarginContainer/HBoxContainer/HBoxContainer2/cost
@onready var well_rate_button: Button = $PanelContainer/MarginContainer/VBoxContainer/well_rate


#signals
signal well_base_increase(value)
signal well_rate_increase(value)
signal spend_mana(value)
signal well_rate_maxed

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_position = get_viewport().get_mouse_position()
			if not self.get_global_rect().has_point(mouse_position):
				close_panel()

func _ready() -> void:
	update_labels()

#cost check functions
func check_well_base_cost(value):
	if well_base_cost.isGreaterThan(value):
		well_base_button.disabled = true
	else:
		well_base_button.disabled = false

func check_well_rate_cost(value):
	if well_rate_max == 0:
		return
	if well_rate_cost.isGreaterThan(value):
		well_rate_button.disabled = true
	else:
		well_rate_button.disabled = false

#update label functions
func update_labels():
	update_well_base_label()
	update_well_rate_label()

func update_well_base_label():
	well_base_label.text = well_base_cost.toAA()

func update_well_rate_label():
	well_rate_label.text = well_rate_cost.toAA()

func _on_well_base_pressed() -> void:
	spend_mana.emit(well_base_cost)
	well_base_increase.emit(well_base_value)
	well_base_cost.multiplyEquals(well_base_cost_inc_rate)
	update_well_base_label()

func close_panel():
	self.visible = false

func _on_well_rate_pressed() -> void:
	spend_mana.emit(well_rate_cost)
	well_rate_increase.emit(well_rate_value)
	well_rate_cost.multiplyEquals(well_rate_cost_inc_rate)
	well_rate_max -= 1
	update_well_rate_label()
	if well_rate_max == 0:
		handle_max_well_rate()

func handle_max_well_rate():
	well_rate_label.text = "MAX"
	well_rate_button.disabled = true
	well_rate_maxed.emit()
