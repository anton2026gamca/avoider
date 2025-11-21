@tool
extends HBoxContainer
class_name PowerChargeMenuOption


@onready var label_node: Label = $Label

@export var label: String
@export_range(0, 5) var initial_count: int
@export_tool_button("Update") var update_btn: Callable = update

@onready var slots: Array[PowerCharge] = [$MarginContainer/HBoxContainer/PowerChargeSlot1, $MarginContainer/HBoxContainer/PowerChargeSlot2, $MarginContainer/HBoxContainer/PowerChargeSlot3, $MarginContainer/HBoxContainer/PowerChargeSlot4, $MarginContainer/HBoxContainer/PowerChargeSlot5]

var full_slots: int = 0

signal insert_requested
signal remove_requested


func _ready() -> void:
	for i in len(slots):
		slots[i].pressed.connect(_on_slot_pressed.bind(i))
		slots[i].set_state(false)
	update()


func update() -> void:
	label_node.text = label


func _on_slot_pressed(id: int) -> void:
	if slots[id].is_full:
		remove_requested.emit()
	else:
		insert_requested.emit()

func insert_power_charge() -> void:
	for i: int in len(slots):
		if not slots[i].is_full:
			slots[i].set_state(true)
			full_slots = i + 1
			break

func remove_power_charge() -> void:
	for i: int in range(len(slots) - 1, -1, -1):
		if slots[i].is_full:
			slots[i].set_state(false)
			full_slots = i
			break
