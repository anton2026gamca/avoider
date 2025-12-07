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
@onready var player_ui: MarginContainer = %PlayerUI
@onready var player_ui_speed_bar: ProgressBar = %SpeedBar

@onready var score_label: Label = %ScoreLabel
@onready var score_animation_player: AnimationPlayer = %ScoreAnimationPlayer

@onready var game_over_menu: Control = $UI/GameOverMenu
@onready var game_over_menu_animation_player: AnimationPlayer = $UI/GameOverMenu/AnimationPlayer

var spawn_timer: float = 0.0

var score: int = 0:
	set(value):
		if value > score and score_animation_player:
			score_animation_player.play("Add" + str(randi_range(1, 2)))
		if score_label:
			get_tree().create_timer(0.1, false).timeout.connect(func() -> void: score_label.text = str(value))
		score = value
	get: return score


func _ready() -> void:
	get_tree().paused = true
	player.visible = false
	player_ui.visible = false
	score_label.text = "0"
	game_over_menu.visible = false
	player.died.connect(game_over)

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
	var m: Meteoroid = meteoroid_scene.instantiate()
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_distance
	m.position = player.global_position + offset
	var velocity_magnitude = randf_range(min_velocity, max_velocity)
	var velocity_angle = randf() * TAU
	var initial_velocity = Vector2(cos(velocity_angle), sin(velocity_angle)) * velocity_magnitude
	m.linear_velocity = initial_velocity
	m.angular_velocity = randf_range(-2.0, 2.0)
	m.destroyed.connect(_on_meteoroid_destroyed)
	world.add_child(m)

func countdown_finish() -> void:
	get_tree().paused = false
	player.visible = true
	player_ui.visible = true

func _on_power_split_changed(values: Dictionary[String, float], group: String) -> void:
	if group == "Movement" and player:
		player.acceleration_multiplier = values.get("Acceleration", 1.0)
		player.max_speed_multiplier = values.get("Max Speed", 1.0)
		player.rotation_speed_multiplier = values.get("Rotation Speed", 1.0)
	elif group == "Shields" and player:
		player.shields_capacity_multiplier = values.get("Capacity", 1.0)
		player.shields_recharge_rate_multiplier = values.get("Recharge", 1.0)

func _on_meteoroid_destroyed() -> void:
	score += 50

func game_over() -> void:
	game_over_menu.visible = true
	game_over_menu_animation_player.play("open")
	player_ui.visible = false

func _on_game_over_menu_restart_pressed() -> void:
	if game_over_menu_animation_player.is_playing():
		return
	game_over_menu_animation_player.play("close")
	await game_over_menu_animation_player.animation_finished
	restart()

func restart() -> void:
	get_tree().reload_current_scene()
