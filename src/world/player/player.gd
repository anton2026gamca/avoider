extends CharacterBody2D
class_name Player


@export_group("Movement")
@export var _acceleration: float = 400.0
var acceleration_multiplier: float = 1.0
var acceleration: float = 400.0:
	set(value): return
	get: return _acceleration * acceleration_multiplier

@export var _max_speed: float = 1000.0
var max_speed_multiplier: float = 1.0:
	set(value):
		max_speed_multiplier = value
		speed_bar.max_value = max_speed
	get: return max_speed_multiplier
var max_speed: float = 1000.0:
	set(value): return
	get: return _max_speed * max_speed_multiplier

@export var _rotation_speed: float = 3.0
var rotation_speed_multiplier: float = 1.0
var rotation_speed: float = 3.0:
	set(value): return
	get: return _rotation_speed * rotation_speed_multiplier

@export var collision_damping: float = 0.5
@export var collision_push_force: float = 0.5
@onready var acceleration_particles: CPUParticles2D = $AccelerationParticles

@export_group("Shooting")
@export var bullet_scene: PackedScene
@onready var bullet_pivot: Node2D = $BulletPivot

@export_group("Shields")
@export var _shields_capacity: float = 20
var shields_capacity_multiplier: float = 1.0:
	set(value):
		shields_capacity_multiplier = value
		if shields_bar:
			shields_bar.max_value = shields_capacity
	get: return shields_capacity_multiplier
var shields_capacity: float = 3.0:
	set(value): return
	get: return _shields_capacity * shields_capacity_multiplier

@export var _shields_recharge_rate: float = 5.0
var shields_recharge_rate_multiplier: float = 1.0
var shields_recharge_rate: float = 3.0:
	set(value): return
	get: return _shields_recharge_rate * shields_recharge_rate_multiplier

var shields_value: float = 0

@export_group("UI")
@export var shields_bar: ProgressBar
@export var damage_bar: ProgressBar
@export var speed_bar: ProgressBar

@onready var sprite: Sprite2D = $Sprite2D
@onready var death_particles: CPUParticles2D = $DeathParticles
@onready var accelerate_audio: EngineSound = $AccelerateAudio
@onready var die_audio: AudioStreamPlayer = $DieAudio
@onready var collide_audio: AudioStreamPlayer = $CollideAudio

var damage: float = 0
var is_dead: bool = false
var speed: float = 0

signal died


func _ready() -> void:
	speed_bar.max_value = max_speed
	shields_bar.max_value = shields_capacity

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	if is_action_just_pressed("shoot"):
		shoot()
	shields_value = min(shields_value + shields_recharge_rate * delta, shields_capacity)
	shields_bar.value = shields_value


func is_action_pressed(action_name: String) -> bool:
	return Input.is_action_pressed(action_name) and not is_dead

func is_action_just_pressed(action_name: String) -> bool:
	return Input.is_action_just_pressed(action_name) and not is_dead

func handle_movement(delta: float) -> void:
	var turn_dir: float = 0
	if is_action_pressed("move_left"):
		turn_dir -= 1
	if is_action_pressed("move_right"):
		turn_dir += 1
	rotation += turn_dir * rotation_speed * delta
	
	if is_action_pressed("move_up"):
		velocity += Vector2.UP.rotated(rotation) * acceleration * delta
		acceleration_particles.emitting = true
		accelerate_audio.pitch_scale = min(accelerate_audio.pitch_scale + 5.0 * delta, 1.0 * acceleration_multiplier * velocity.length() / max_speed)
	else:
		acceleration_particles.emitting = false
		accelerate_audio.pitch_scale = max(accelerate_audio.pitch_scale - 0.5 * delta, 0.01)
	if is_action_pressed("move_down"):
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	speed = velocity.length()
	speed_bar.value = speed
	move_and_slide()
	var collision_count = get_slide_collision_count()
	if collision_count > 0:
		handle_collisions()

func shoot() -> void:
	var bullet: Node = bullet_scene.instantiate()
	if bullet is Bullet:
		bullet.velocity = velocity
		bullet.global_position = bullet_pivot.global_position
		bullet.rotation = rotation
		get_parent().add_child(bullet)
	else:
		bullet.queue_free()

func take_damage(value: float) -> void:
	shields_value -= value
	if shields_value < 0:
		damage += abs(shields_value)
		damage_bar.value = damage
		shields_value = 0
	if damage >= 100:
		die()

func die() -> void:
	death_particles.restart()
	sprite.visible = false
	collision_layer = 0
	collision_mask = 0
	is_dead = true
	die_audio.play()
	died.emit()

func handle_collisions() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Meteoroid:
			var push_direction = collision.get_normal() * -1
			var push_force = velocity.length() * collision_push_force
			var collision_point = collision.get_position()
			var hit_val: float = (push_direction * push_force).length() * 0.05
			collider.apply_impulse(push_direction * push_force, collision_point - collider.global_position)
			collider.damage(hit_val)
			take_damage(hit_val)
			collide_audio.pitch_scale = hit_val / 40.0
			collide_audio.play()
			velocity *= (1.0 - collision_damping)
