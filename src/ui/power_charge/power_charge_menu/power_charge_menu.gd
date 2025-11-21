@tool
extends VBoxContainer
class_name PowerChargeMenu


@export var label: String
@onready var label_node: Label = %Label

var available_power_charges: int = 0:
	set(value):
		available_power_charges = value
		if available_power_charges_label:
			available_power_charges_label.text = str(available_power_charges)
	get:
		return available_power_charges
@onready var available_power_charges_label: Label = %PowerChargesCount

@export var options: Array[PowerChargeOptionData]
@export_tool_button("Update") var update_btn: Callable = update
@onready var options_parent: VBoxContainer = %OptionsParent
const POWER_CHARGE_MENU_OPTION: PackedScene = preload("uid://iyq52j6q4y68")

signal changed(option: String, value: int)


func _ready() -> void:
	update()


func update() -> void:
	label_node.text = label
	for child: Node in options_parent.get_children():
		options_parent.remove_child(child)
		child.queue_free()
	for option: PowerChargeOptionData in options:
		var node: PowerChargeMenuOption = POWER_CHARGE_MENU_OPTION.instantiate()
		node.label = option.label
		node.initial_count = option.default_value
		node.insert_requested.connect(_on_option_insert_requested.bind(node))
		node.remove_requested.connect(_on_option_remove_requested.bind(node))
		options_parent.add_child(node)
		available_power_charges += option.default_value
	if available_power_charges_label:
		available_power_charges_label.text = str(available_power_charges)


func _on_option_insert_requested(option: PowerChargeMenuOption) -> void:
	if available_power_charges > 0:
		available_power_charges -= 1
		option.insert_power_charge()
		changed.emit(option.label, option.full_slots)

func _on_option_remove_requested(option: PowerChargeMenuOption) -> void:
	available_power_charges += 1
	option.remove_power_charge()
	changed.emit(option.label)
