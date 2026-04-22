extends Control

@onready var upgrade_data : Dictionary = {
	"well_base" : {
		"button" : $PanelContainer/MarginContainer/VBoxContainer/well_base,
		"label" : $PanelContainer/MarginContainer/VBoxContainer/well_base/MarginContainer/HBoxContainer/HBoxContainer2/cost,
		"signal" : well_base_increase,
		"cost" : Big.new(1, 2),
		"cost_signal" : spend_mana,
		"inc_rate" : Big.new(5, 0),
		"value" : Big.new(5, 1),
		"max" : 10,
		},
	"well_rate" : {
		"button" : $PanelContainer/MarginContainer/VBoxContainer/well_rate,
		"label" : $PanelContainer/MarginContainer/VBoxContainer/well_rate/MarginContainer/HBoxContainer/HBoxContainer2/cost,
		"signal" : well_rate_increase,
		"cost" : Big.new(1, 3),
		"cost_signal" : spend_mana,
		"inc_rate" : Big.new(3, 0),
		"value" : 1,
		"max" : 4,
	},
	"well_mult" : {
		"button" : $PanelContainer/MarginContainer/VBoxContainer/well_mult,
		"label" : $PanelContainer/MarginContainer/VBoxContainer/well_mult/MarginContainer/HBoxContainer/HBoxContainer2/cost,
		"signal" : well_mult_increase,
		"cost" : Big.new(1, 1),
		"cost_signal" : spend_rune,
		"inc_rate" : Big.new(1, 2),
		"value" : Big.new(1, 0),
		"max" : 4,
	}
}

#signals
signal spend_mana(value)
signal spend_rune(value)
signal well_base_increase(value)
signal well_rate_increase(value)
signal well_mult_increase(value)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_position = get_viewport().get_mouse_position()
			if not self.get_global_rect().has_point(mouse_position):
				close_panel()

func _ready() -> void:
	update_labels()

#cost check functions
func check_cost(type, value):
	var upgrade_list : Dictionary = {
		"mana" : ["well_base", "well_rate"],
		"rune" : ["well_mult"]
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

#update label functions
func update_labels():
	for upgrade in upgrade_data:
		update_label(upgrade)

func update_label(upgrade):
	upgrade_data[upgrade]["label"].text = upgrade_data[upgrade]["cost"].toAA()

func close_panel():
	self.visible = false

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

func _on_well_base_pressed() -> void:
	handle_upgrade("well_base")

func _on_well_rate_pressed() -> void:
	handle_upgrade("well_rate")

func _on_well_mult_pressed() -> void:
	handle_upgrade("well_mult")
