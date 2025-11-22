@tool
extends VBoxContainer
class_name PowerSplitSettingsGroup


@export var label: String
@onready var label_node: Label = %GroupLabel

@export var options: Array[PowerSplitSettingData]
var option_nodes: Dictionary[PowerSplitSettingData, PowerSplitSetting]
@export_tool_button("Reload") var reload_btn: Callable = reload
@onready var options_parent: VBoxContainer = %OptionsParent
const POWER_CHARGE_MENU_OPTION: PackedScene = preload("uid://iyq52j6q4y68")

signal changed(option: String, value: int)


func _ready() -> void:
	reload()


func reload() -> void:
	option_nodes = {}
	label_node.text = label
	for child: Node in options_parent.get_children():
		options_parent.remove_child(child)
		child.queue_free()
	for option: PowerSplitSettingData in options:
		var node: PowerSplitSetting = POWER_CHARGE_MENU_OPTION.instantiate()
		node.label = option.label
		node.initial_value = option.default_value
		node.max_value = option.max_value
		node.changed.connect(_on_option_changed.bind(node))
		options_parent.add_child(node)
		option_nodes[option] = node
	update()


func update(force_keep: PowerSplitSetting = null) -> void:
	var adjust_options: Array[PowerSplitSetting] = []
	var total: float = 0
	for option: PowerSplitSettingData in options:
		if not option in option_nodes:
			continue
		var node: PowerSplitSetting = option_nodes[option]
		total += node.value
		if node == force_keep:
			continue
		adjust_options.append(node)
	if len(adjust_options) <= 0:
		return
	const target: float = 100.0
	for i in range(100):
		for option: PowerSplitSetting in adjust_options:
			var add: float = max(min(option.value + (target - total), option.max_value), 0) - option.value
			option.value += add
			total += add
		if total == target:
			break

func _on_option_changed(option: PowerSplitSetting) -> void:
	update(option)
