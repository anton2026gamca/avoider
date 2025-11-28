extends RigidBody2D
class_name Meteoroid


var health: float = 500
var radius: float = 0

@onready var lines: Array[Line2D] = [$Line1, $Line2, $Line3, $Line4, $Line5, $Line6, $Line7]
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var random_size_multiplier_min: float = 0.8
@export var random_size_multiplier_max: float = 1.3


func _ready() -> void:
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape = collision_shape.shape.duplicate()
		collision_shape.shape.radius *= randf_range(random_size_multiplier_min, random_size_multiplier_max)
		radius = collision_shape.shape.radius
	var angles: Array[float] = []
	var radius_modifiers: Array[float] = []
	var count: int = len(lines)
	var val: float = 0
	angles.append(0)
	radius_modifiers.append(1)
	for i: float in count - 1:
		var step: float = deg_to_rad(randf_range((1.0 / count) * 360 - 10, (1.0 / count) * 360) + 10)
		val += step
		angles.append(val)
		radius_modifiers.append(randf_range(0.7, 1.3))
	angles.append(0)
	radius_modifiers.append(1)
	for i: float in count:
		lines[i].points[0] = Vector2.from_angle(angles[i]) * radius * radius_modifiers[i]
		lines[i].points[1] = Vector2.from_angle(angles[i + 1]) * radius * radius_modifiers[i + 1]


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
		tween.set_parallel()
		tween.tween_property(line, "rotation", line.rotation + deg_to_rad(randf_range(-90, 90)), 0.5)
	await get_tree().create_timer(0.5, false).timeout
	get_parent().remove_child(self)
	queue_free()
