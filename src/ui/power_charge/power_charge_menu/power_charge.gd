extends TextureButton
class_name PowerCharge


@export_group("Empty Textures")
@export var empty_normal: Texture2D
@export var empty_pressed: Texture2D
@export var empty_hover: Texture2D
@export var empty_focused: Texture2D

@export_group("Full Textures")
@export var full_normal: Texture2D
@export var full_pressed: Texture2D
@export var full_hover: Texture2D
@export var full_focused: Texture2D

var is_full: bool = false


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass


func set_state(val: bool) -> void:
	is_full = val
	if is_full:
		texture_normal = full_normal
		texture_pressed = full_pressed
		texture_hover = full_hover
		texture_focused = full_focused
	else:
		texture_normal = empty_normal
		texture_pressed = empty_pressed
		texture_hover = empty_hover
		texture_focused = empty_focused
