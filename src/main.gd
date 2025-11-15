extends Node2D
class_name Main


@export var meteoroid_scene: PackedScene
@export var spawn_interval: float = 0.1  # Time between spawns in seconds
@export var spawn_distance: float = 600.0  # Distance from player to spawn meteoroids
@export var min_velocity: float = 50.0  # Minimum initial velocity
@export var max_velocity: float = 200.0  # Maximum initial velocity
@export var max_meteoroids: int = 50  # Maximum number of meteoroids at once

@onready var player: Player = $Player

var spawn_timer: float = 0.0


func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval and get_tree().get_nodes_in_group("meteoroids").size() < 40:
		spawn_timer = 0.0
		spawn_meteoroid()
	for m: Meteoroid in get_tree().get_nodes_in_group("meteoroids"):
		if m.position.distance_squared_to(player.position) >= 1000 * 1000:
			remove_child(m)
			m.queue_free()


func spawn_meteoroid() -> void:
	if not player:
		return
	var m: RigidBody2D = meteoroid_scene.instantiate()
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_distance
	m.position = player.global_position + offset
	var velocity_magnitude = randf_range(min_velocity, max_velocity)
	var velocity_angle = randf() * TAU
	var initial_velocity = Vector2(cos(velocity_angle), sin(velocity_angle)) * velocity_magnitude
	m.linear_velocity = initial_velocity
	m.angular_velocity = randf_range(-2.0, 2.0)
	add_child(m)
