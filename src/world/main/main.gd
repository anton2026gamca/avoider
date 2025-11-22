extends Node2D
class_name Main


@export var meteoroid_scene: PackedScene
@export var spawn_interval: float = 0.1 
@export var spawn_distance: float = 600.0
@export var min_velocity: float = 25.0
@export var max_velocity: float = 100.0
@export var max_meteoroids: int = 50

@onready var world: Node2D = %World
@onready var player: Player = %Player
@onready var player_ui: MarginContainer = $UI/PlayerUI
@onready var player_ui_speed_bar: ProgressBar = $UI/PlayerUI/VBoxContainer/Stats/MarginContainer/VBoxContainer/Speed/ProgressBar
@onready var animation_player: AnimationPlayer = $UI/Countdown/AnimationPlayer
@onready var player_power_split_group: PowerSplitSettingsGroup = $UI/PlayerUI/VBoxContainer/PanelContainer/MarginContainer/PowerSplitSettingsGroup

var spawn_timer: float = 0.0


func _ready() -> void:
	get_tree().paused = true
	player.visible = false
	player_ui.visible = false

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval and get_tree().get_nodes_in_group("meteoroids").size() < 40:
		spawn_timer = 0.0
		spawn_meteoroid()
	for m: Meteoroid in get_tree().get_nodes_in_group("meteoroids"):
		if m.position.distance_squared_to(player.position) >= 1000 * 1000:
			world.remove_child(m)
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
	world.add_child(m)

func countdown_finish() -> void:
	get_tree().paused = false
	player.visible = true
	player_ui.visible = true


func _on_power_split_changed(values: Dictionary[String, float], group: String) -> void:
	if group == "Player" and player:
		player.acceleration_multiplier = values.get("Acceleration", 1.0)
		player.max_speed_multiplier = values.get("Max Speed", 1.0)
		player.rotation_speed_multiplier = values.get("Rotation Speed", 1.0)
