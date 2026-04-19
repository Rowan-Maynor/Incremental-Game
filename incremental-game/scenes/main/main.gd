extends Node2D

var mana : Big = Big.new(0)
var rune : Big = Big.new(0)

#interactables
@onready var orb : Node2D = $SubViewportContainer/SubViewport/floor_1/Orb
@onready var stone: Node2D = $SubViewportContainer/SubViewport/floor_2/Stone

#resource value lables
@onready var mana_label : Label = $ui/resource_containers/mana_container/HBoxContainer/VBoxContainer/Label
@onready var rune_label : Label = $ui/resource_containers/rune_container/HBoxContainer/VBoxContainer/Label

@onready var popup_labels: CanvasLayer = $popup_labels

func _ready() -> void:
	set_big_properties()
	orb.connect("gain_mana", gain_mana)
	stone.connect("gain_rune", gain_rune)

func _process(_delta: float) -> void:
	mana_label.text = mana.toAA()
	rune_label.text = rune.toAA()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("close_game"):
		get_tree().quit()

#resource math functions
#src is necessary to help control spawn_label positioning
func gain_mana(value, src):
	mana = mana.plus(value)
	spawn_label("mana", value, src)

func gain_rune(value, src):
	rune = rune.plus(value)
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
