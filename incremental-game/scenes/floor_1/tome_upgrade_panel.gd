extends Control

@onready var upgrade_data : Dictionary = {
	"orb_click_base" : {
		"button" : $PanelContainer/MarginContainer/VBoxContainer/click_base,
		"label" : $PanelContainer/MarginContainer/VBoxContainer/click_base/MarginContainer/HBoxContainer/HBoxContainer2/cost,
		"signal" : orb_click_base_increase,
		"cost" : Big.new(1, 1),
		"cost_signal" : spend_mana,
		"inc_rate" : Big.new(5, 0),
		"value" : Big.new(1, 0),
		"max" : 4,
		},
	"orb_auto_click" : {
		"button" : $PanelContainer/MarginContainer/VBoxContainer/orb_auto_click,
		"label" : $PanelContainer/MarginContainer/VBoxContainer/orb_auto_click/MarginContainer/HBoxContainer/HBoxContainer2/cost,
		"signal" : orb_auto_click,
		"cost" : Big.new(2, 1),
		"cost_signal" : spend_rune,
		"inc_rate" : Big.new(1, 0),
		"value" : true,
		"max" : 1,
	},
	"orb_auto_rate" : {
		"button" : $PanelContainer/MarginContainer/VBoxContainer/orb_auto_rate,
		"label" : $PanelContainer/MarginContainer/VBoxContainer/orb_auto_rate/MarginContainer/HBoxContainer/HBoxContainer2/cost,
		"signal" : orb_auto_rate_increase,
		"cost" : Big.new(5, 1),
		"cost_signal" : spend_rune,
		"inc_rate" : Big.new(1, 1),
		"value" : 0.1,
		"max" : 9,
	}
}

signal orb_click_base_increase(value)
signal orb_auto_click()
signal orb_auto_rate_increase(value)
signal spend_mana(value)
signal spend_rune(value)

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
		"mana" : ["orb_click_base"],
		"rune" : ["orb_auto_click", "orb_auto_rate"]
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

func _on_click_base_pressed() -> void:
	handle_upgrade("orb_click_base")

func _on_orb_auto_click_pressed() -> void:
	handle_upgrade("orb_auto_click")

func _on_orb_auto_rate_pressed() -> void:
	handle_upgrade("orb_auto_rate")
