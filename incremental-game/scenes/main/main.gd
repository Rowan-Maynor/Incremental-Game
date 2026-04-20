extends Node2D

var mana : Big = Big.new(0)
var rune : Big = Big.new(0)

#interactables
@onready var orb : Node2D = $SubViewportContainer/SubViewport/floor_1/Orb
@onready var stone : Node2D = $SubViewportContainer/SubViewport/floor_2/Stone
@onready var mana_well : Node2D = $SubViewportContainer/SubViewport/floor_1/ManaWell
@onready var tome : Node2D = $SubViewportContainer/SubViewport/floor_1/Tome

#floor_bricks
@onready var floor_2_bricks : Control = $SubViewportContainer/SubViewport/floor_2/Bricks

#resource value lables
@onready var mana_label : Label = $ui/resource_containers/mana_container/HBoxContainer/VBoxContainer/Label
@onready var rune_label : Label = $ui/resource_containers/rune_container/HBoxContainer/VBoxContainer/Label

@onready var popup_labels: CanvasLayer = $popup_labels

func _ready() -> void:
	set_big_properties()
	connect_signals()

func _process(_delta: float) -> void:
	mana_label.text = mana.toAA()
	rune_label.text = rune.toAA()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("close_game"):
		get_tree().quit()

#resource math functions
#src is necessary to help control spawn_label positioning
func gain_mana(value, src):
	mana.plusEquals(value)
	curr_mana.emit(mana)
	spawn_label("mana", value, src)

func gain_rune(value, src):
	rune.plusEquals(value)
	curr_rune.emit(rune)
	spawn_label("rune", value, src)

#helper functions
func spawn_label(type : String, value : Big, src : String):
	var label : Control = load("res://scenes/ui_components/resource_label.tscn").instantiate()
	
	label.type = type
	label.value = value
	
	#position needs to be set differently based on src
	if src == "orb" or "stone":
		label.position = get_global_mouse_position()
	
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

#signal functions
func connect_signals():
	#orb signals
	orb.connect("gain_mana", gain_mana)
	
	#tome signals
	curr_mana.connect(tome.check_unlock)
	tome.tome_unlocked.connect(tome_unlocked)
	
	#stone signals
	stone.connect("gain_rune", gain_rune)
	curr_mana.connect(stone.check_unlock)
	stone.stone_unlocked.connect(stone_unlocked)
	stone.unlock_floor.connect(floor_2_bricks.unlock_floor)

func tome_unlocked():
	curr_mana.disconnect(tome.check_unlock)

func stone_unlocked():
	curr_mana.disconnect(stone.check_unlock)
	print(curr_mana.get_connections())

#signals
signal curr_mana(value)
signal curr_rune(value)
