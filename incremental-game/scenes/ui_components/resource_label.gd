extends Control

var type : String = "mana"
var value : Big

@onready var icon = $HBoxContainer/icon
@onready var label = $HBoxContainer/VBoxContainer/Label

var icon_paths : Dictionary = {
	"mana": "res://assets/ui/mana_icon.png",
	"rune": "res://assets/ui/rune_icon.png"
}
func _ready() -> void:
	var texture : Texture = load(icon_paths[type])
	icon.texture = texture
	label.text = value.toAA()
