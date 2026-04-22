extends Control

@onready var upgrade_data : Dictionary = {
	"stone_swing_power" : {
		"button" : $PanelContainer/MarginContainer/VBoxContainer/swing_power,
		"label" : $PanelContainer/MarginContainer/VBoxContainer/swing_power/MarginContainer/HBoxContainer/HBoxContainer2/cost,
		"signal" : stone_swing_power_increase,
		"cost" : Big.new(5, 3),
		"cost_signal" : spend_mana,
		"inc_rate" : Big.new(2, 0),
		"value" : 1.0,
		"max" : 9,
		},
	"stone_base" : {
		"button" : $PanelContainer/MarginContainer/VBoxContainer/stone_base,
		"label" : $PanelContainer/MarginContainer/VBoxContainer/stone_base/MarginContainer/HBoxContainer/HBoxContainer2/cost,
		"signal" : stone_base_increase,
		"cost" : Big.new(2, 1),
		"cost_signal" : spend_rune,
		"inc_rate" : Big.new(3, 0),
		"value" : Big.new(1, 0),
		"max" : 9,
		},
	"stone_auto_click" : {
		"button" : $PanelContainer/MarginContainer/VBoxContainer/stone_auto_click,
		"label" : $PanelContainer/MarginContainer/VBoxContainer/stone_auto_click/MarginContainer/HBoxContainer/HBoxContainer2/cost,
		"signal" : stone_auto_click,
		"cost" : Big.new(1, 3),
		"cost_signal" : spend_rune,
		"inc_rate" : Big.new(5, 0),
		"value" : true,
		"max" : 1,
		},
}

signal spend_mana(value)
signal spend_rune(value)
signal stone_swing_power_increase()
signal stone_base_increase()
signal stone_auto_click()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_position = get_viewport().get_mouse_position()
			if not self.get_global_rect().has_point(mouse_position):
				close_panel()

func _ready() -> void:
	Big.setSmallDecimals(0)
	update_labels()

func check_cost(type, value):
	var upgrade_list : Dictionary = {
		"mana" : ["stone_swing_power"],
		"rune" : ["stone_base", "stone_auto_click"]
	}
	
	for upgrade in upgrade_list[type]:
		if not upgrade:
			continue
		if upgrade_data[upgrade]["max"] == 0:
			continue
		if upgrade_data[upgrade]["cost"].isGreaterThan(value):
			upgrade_data[upgrade]["button"].disabled = true
		else:
			upgrade_data[upgrade]["button"].disabled = false

func update_labels():
	for upgrade in upgrade_data:
		update_label(upgrade)

func update_label(upgrade):
	upgrade_data[upgrade]["label"].text = upgrade_data[upgrade]["cost"].toAA()

func handle_upgrade(upgrade : String):
	#storing the cost and then calling spend mana after the calculations fixes a bug.
	#signal was resolving before the cost increased, so the button would be
	#active despite not having enough mana for the next upgrade.
	##Big must be new or the increased cost will be deducted from mana!!
	var curr_cost = Big.new(upgrade_data[upgrade]["cost"])
	upgrade_data[upgrade]["signal"].emit(upgrade_data[upgrade]["value"])
	upgrade_data[upgrade]["cost"].multiplyEquals(upgrade_data[upgrade]["inc_rate"])
	upgrade_data[upgrade]["cost_signal"].emit(curr_cost)
	upgrade_data[upgrade]["max"] -= 1
	update_label(upgrade)
	if upgrade_data[upgrade]["max"] == 0:
		handle_max_upgrade(upgrade)

func handle_max_upgrade(upgrade : String):
	upgrade_data[upgrade]["label"].text = "MAX"
	upgrade_data[upgrade]["button"].disabled = true

func close_panel():
	self.visible = false

func _on_swing_power_pressed() -> void:
	handle_upgrade("stone_swing_power")

func _on_stone_base_pressed() -> void:
	handle_upgrade("stone_base")

func _on_stone_auto_click_pressed() -> void:
	handle_upgrade("stone_auto_click")
