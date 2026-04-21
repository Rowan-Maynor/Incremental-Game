extends Control

var orb_click_base_cost : Big = Big.new(1, 1)
var orb_click_base_cost_inc_rate : Big = Big.new(2, 0)
var orb_click_base_value : Big = Big.new(1, 0)

@onready var orb_click_base_label: Label = $PanelContainer/MarginContainer/VBoxContainer/click_base/MarginContainer/HBoxContainer/HBoxContainer2/cost
@onready var click_base_button: Button = $PanelContainer/MarginContainer/VBoxContainer/click_base

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_position = get_viewport().get_mouse_position()
			if not self.get_global_rect().has_point(mouse_position):
				close_panel()

func _ready() -> void:
	Big.setSmallDecimals(0)
	update_click_base_label()

func check_orb_click_base_cost(value):
	if orb_click_base_cost.isGreaterThan(value):
		click_base_button.disabled = true
	else:
		click_base_button.disabled = false

func update_click_base_label():
	orb_click_base_label.text = orb_click_base_cost.toAA()

func _on_click_base_pressed() -> void:
	#storing the cost and then calling spend mana after the calculations fixes a bug.
	#spend_mana signal was resolving before the cost increased, so the button would be
	#active despite not having enough mana for the next upgrade.
	##Big must be new or the increased cost will be deducted from mana!!
	var curr_cost : Big = Big.new(orb_click_base_cost)
	orb_click_base_increase.emit(orb_click_base_value)
	orb_click_base_cost.multiplyEquals(orb_click_base_cost_inc_rate)
	spend_mana.emit(curr_cost)
	update_click_base_label()

func close_panel():
	self.visible = false

signal orb_click_base_increase(value)
signal spend_mana(value)
