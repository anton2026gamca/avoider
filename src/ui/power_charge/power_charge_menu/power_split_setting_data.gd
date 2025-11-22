extends Resource
class_name PowerSplitSettingData


@export var label: String
@export_range(0, 100) var max_value: float = 100
@export_range(0, 100) var default_value: float
