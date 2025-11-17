extends RigidBody2D
class_name Meteoroid


@export var lines: Array[Line2D]

var health: float = 500


func damage(val: float) -> void:
	health -= val
	if health <= 0:
		destroy()

func destroy() -> void:
	if collision_layer == 0:
		return
	collision_layer = 0
	angular_velocity = 0
	for line: Line2D in lines:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(line, "position", line.position + Vector2(randi_range(-75, 75), randi_range(-75, 75)), 0.5)
	await get_tree().create_timer(0.5, false).timeout
	get_parent().remove_child(self)
	queue_free()
