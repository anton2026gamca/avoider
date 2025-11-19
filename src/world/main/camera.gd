extends Camera2D
class_name Camera


@export var player: Player


func _process(_delta: float) -> void:
	position = player.position
	rotation = player.rotation
