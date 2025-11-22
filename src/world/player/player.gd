extends CharacterBody2D
class_name Player


@export_group("Movement")
@export var full_acceleration: float = 400.0
var acceleration_multiplier: float = 1.0
var acceleration: float = 400.0:
	set(value): return
	get: return full_acceleration * acceleration_multiplier

@export var full_max_speed: float = 1000.0
var max_speed_multiplier: float = 1.0:
	set(value):
		max_speed_multiplier = value
		speed_bar.max_value = max_speed
	get: return max_speed_multiplier
var max_speed: float = 1000.0:
	set(value): return
	get: return full_max_speed * max_speed_multiplier

@export var full_rotation_speed: float = 3.0
var rotation_speed_multiplier: float = 1.0
var rotation_speed: float = 3.0:
	set(value): return
	get: return full_rotation_speed * rotation_speed_multiplier

@export var collision_damping: float = 0.5
@export var collision_push_force: float = 0.5
@onready var acceleration_particles: CPUParticles2D = $AccelerationParticles

@export_group("Shooting")
@export var bullet_scene: PackedScene
@onready var bullet_pivot: Node2D = $BulletPivot

@export_group("UI")
@export var damage_bar: ProgressBar
@export var speed_bar: ProgressBar


var damage: float = 0
var speed: float = 0


func _ready() -> void:
	speed_bar.max_value = max_speed

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	if Input.is_action_just_pressed("shoot"):
		shoot()


func handle_movement(delta: float) -> void:
	var turn_dir: float = 0
	if Input.is_action_pressed("move_left"):
		turn_dir -= 1
	if Input.is_action_pressed("move_right"):
		turn_dir += 1
	rotation += turn_dir * rotation_speed * delta
	
	if Input.is_action_pressed("move_up"):
		velocity += Vector2.UP.rotated(rotation) * acceleration * delta
		acceleration_particles.emitting = true
	else:
		acceleration_particles.emitting = false
	if Input.is_action_pressed("move_down"):
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
			damage += hit_val
			damage_bar.value = damage
			velocity *= (1.0 - collision_damping)
