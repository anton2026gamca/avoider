@tool
extends HBoxContainer
class_name PowerSplitSetting


@onready var label_node: Label = %Label

@export var label: String
@export_range(0, 100) var initial_value: float
@export_range(0, 100) var max_value: float = 100.0
@onready var slider: HSlider = %Slider
@onready var value_label: Label = %ValueLabel
@export_tool_button("Update") var update_btn: Callable = update

signal changed

var value: float:
	set(val):
		slider.value = val
		value_label.text = str(int(val))
	get: return slider.value


func _ready() -> void:
	slider.value_changed.connect(_on_slider_changed)
	update()


func update() -> void:
	label_node.text = label
	slider.value = initial_value
	slider.max_value = max_value


func _on_slider_changed(_value: float) -> void:
	changed.emit()
