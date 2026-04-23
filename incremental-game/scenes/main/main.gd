extends Node2D

var mana : Big = Big.new(0)
var rune : Big = Big.new(0)

#interactables
@onready var orb : Node2D = $SubViewportContainer/SubViewport/floor_1/Orb
@onready var stone : Node2D = $SubViewportContainer/SubViewport/floor_2/Stone
@onready var mana_well : Node2D = $SubViewportContainer/SubViewport/floor_1/ManaWell
@onready var tome : Node2D = $SubViewportContainer/SubViewport/floor_1/Tome
@onready var tool_shed : Node2D = $SubViewportContainer/SubViewport/floor_2/ToolShed
@onready var craft_table : Node2D = $SubViewportContainer/SubViewport/floor_2/CraftTable

#upgrade panels
@onready var tome_upgrade_panel : Control = $upgrade_panels/TomeUpgradePanel
@onready var well_upgrade_panel : Control = $upgrade_panels/ManaWellUpgradePanel
@onready var tool_shed_upgrade_panel : Control = $upgrade_panels/ToolShedUpgradePanel
@onready var craft_table_upgrade_panel : Control = $upgrade_panels/CraftsmanTableUpgradePanel

#floor_bricks
@onready var floor_1_bricks : Control = $SubViewportContainer/SubViewport/floor_1/Bricks
@onready var floor_2_bricks : Control = $SubViewportContainer/SubViewport/floor_2/Bricks

#resource value lables
@onready var mana_label : Label = $ui/resource_containers/mana_container/HBoxContainer/VBoxContainer/Label
@onready var rune_label : Label = $ui/resource_containers/rune_container/HBoxContainer/VBoxContainer/Label
@onready var popup_labels: CanvasLayer = $popup_labels

#save properties
#must increment when any fields are added/removed from save data
var latest_save_version : int = 1
var save_data : Dictionary = {
	"version" : 0,
	"seen_rune" : false,
}

#signals
signal curr_mana(type, value)
signal curr_rune(type, value)

func _ready() -> void:
	load_game()
	set_big_properties()
	connect_signals()
	handle_unlocks()

func _process(_delta: float) -> void:
	mana_label.text = mana.toAA()
	rune_label.text = rune.toAA()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("close_game"):
		get_tree().quit()
	if Input.is_action_just_pressed("add_1k_mana"):
		gain_mana(Big.new(1, 3), "orb")
	if Input.is_action_just_pressed("add_1k_rune"):
		gain_rune(Big.new(1, 3), "stone")

#resource math functions
#src is necessary to help control spawn_label positioning
func gain_mana(value, src):
	mana.plusEquals(value)
	curr_mana.emit("mana", mana)
	spawn_label("mana", value, src)

func spend_mana(value):
	mana.minusEquals(value)
	curr_mana.emit("mana", mana)

func gain_rune(value, src):
	rune.plusEquals(value)
	curr_rune.emit("rune", rune)
	spawn_label("rune", value, src)

func spend_rune(value):
	rune.minusEquals(value)
	curr_rune.emit("rune", rune)

#helper functions
func spawn_label(type : String, value : Big, src : String):
	var label : Control = load("res://scenes/ui_components/resource_label.tscn").instantiate()
	
	label.type = type
	label.value = value
	
	#position needs to be set differently based on src
	if src == "orb" or src == "stone":
		label.position = get_global_mouse_position()
	elif src == "well":
		var pos_x : int = randi_range(375, 425)
		var pos_y : int = randi_range(300, 325)
		var pos_final : Vector2 = Vector2(pos_x, pos_y)
		label.position = pos_final
	elif src == "orb_auto":
		var pos_x : int = randi_range(45, 120)
		var pos_y : int = randi_range(250, 295)
		var pos_final : Vector2 = Vector2(pos_x, pos_y)
		label.position = pos_final
	elif src == "stone_auto":
		var pos_x : int = randi_range(45, 110)
		var pos_y : int = randi_range(145, 115)
		var pos_final : Vector2 = Vector2(pos_x, pos_y)
		label.position = pos_final
	
	#add to main
	popup_labels.add_child(label)
	
	#tween
	var tween = get_tree().create_tween()
	var end_position: Vector2 = label.position
	end_position.y -= 50
	tween.tween_property(label, "position", end_position, 1.0)
	tween.parallel().tween_property(label, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5).set_delay(0.5)
	tween.tween_callback(label.queue_free)

func set_big_properties():
	Big.setSmallDecimals(0)

#save game functions
func save_game():
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	save_file.store_var(save_data.duplicate())
	save_file.close()

func load_game():
	var save_file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var data = save_file.get_var()
	if data["version"] != latest_save_version:
		update_save(data)
		save_game()
	else:
		save_data = data.duplicate()
	save_file.close()

func update_save(data):
	for entry in data:
		if save_data.has(entry):
			save_data[entry] = data[entry]
	save_data["version"] = latest_save_version

#unlock functions
func handle_unlocks():
	if !save_data["seen_rune"]:
		hide_rune_container()

func hide_rune_container():
	$ui/resource_containers/rune_container.visible = false

func show_rune_container():
	$ui/resource_containers/rune_container.visible = true

#signal functions
func connect_signals():
	#floor 1 signals
	curr_mana.connect(floor_1_bricks.check_unlock)
	floor_1_bricks.unlock_stone.connect(stone.check_unlock)
	floor_1_bricks.unlock_floor_2.connect(floor_2_bricks.unlock_floor_2)
	
	#orb signals
	orb.connect("gain_mana", gain_mana)
	
	#tome signals
	curr_mana.connect(tome.check_unlock)
	tome.tome_unlocked.connect(tome_unlocked)
	tome.open_panel.connect(open_tome_upgrade_panel)
	
	#tome upgrade panel signals
	curr_mana.connect(tome_upgrade_panel.check_cost)
	curr_rune.connect(tome_upgrade_panel.check_cost)
	tome_upgrade_panel.spend_mana.connect(spend_mana)
	tome_upgrade_panel.spend_rune.connect(spend_rune)
	tome_upgrade_panel.orb_click_base_increase.connect(orb.increase_base)
	tome_upgrade_panel.orb_auto_click.connect(orb.unlock_auto_click)
	tome_upgrade_panel.orb_auto_rate_increase.connect(orb.increase_auto_rate)
	
	#mana well signals
	curr_mana.connect(mana_well.check_unlock)
	mana_well.open_panel.connect(open_well_upgrade_panel)
	mana_well.gain_mana.connect(gain_mana)
	
	#well upgrade panel signals
	curr_mana.connect(well_upgrade_panel.check_cost)
	curr_rune.connect(well_upgrade_panel.check_cost)
	well_upgrade_panel.spend_mana.connect(spend_mana)
	well_upgrade_panel.spend_rune.connect(spend_rune)
	well_upgrade_panel.well_base_increase.connect(mana_well.increase_base)
	well_upgrade_panel.well_rate_increase.connect(mana_well.increase_rate)
	well_upgrade_panel.well_mult_increase.connect(mana_well.increase_mult)
	
	#stone signals
	stone.connect("gain_rune", gain_rune)
	stone.stone_unlocked.connect(stone_unlocked)
	
	#tool shed signals
	curr_rune.connect(tool_shed.check_unlock)
	tool_shed.open_panel.connect(open_tool_shed_upgrade_panel)
	
	#tool shed upgrade panel signals
	curr_mana.connect(tool_shed_upgrade_panel.check_cost)
	curr_rune.connect(tool_shed_upgrade_panel.check_cost)
	tool_shed_upgrade_panel.spend_mana.connect(spend_mana)
	tool_shed_upgrade_panel.spend_rune.connect(spend_rune)
	tool_shed_upgrade_panel.stone_swing_power_increase.connect(stone.increase_swing_power)
	tool_shed_upgrade_panel.stone_base_increase.connect(stone.increase_base)
	tool_shed_upgrade_panel.stone_auto_click.connect(stone.unlock_auto_click)
	
	#craftsman table signals
	curr_rune.connect(craft_table.check_unlock)
	craft_table.open_panel.connect(open_craft_table_upgrade_panel)

func tome_unlocked():
	curr_mana.disconnect(tome.check_unlock)

func stone_unlocked():
	if not save_data["seen_rune"]:
		save_data["seen_rune"] = true
		save_game()
		show_rune_container()
	curr_mana.disconnect(floor_1_bricks.check_unlock)

#panel functions
func open_tome_upgrade_panel():
	tome_upgrade_panel.visible = true

func open_well_upgrade_panel():
	well_upgrade_panel.visible = true

func open_tool_shed_upgrade_panel():
	tool_shed_upgrade_panel.visible = true

func open_craft_table_upgrade_panel():
	craft_table_upgrade_panel.visible = true
