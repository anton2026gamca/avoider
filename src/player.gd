extends CharacterBody2D
class_name Player


@export var thrust: float = 400.0
@export var max_speed: float = 300.0
@export var rotation_speed: float = 3.0
@export var friction: float = 100.0
@export var collision_damping: float = 0.5
@export var collision_push_force: float = 0.5

@onready var acceleration_particles: CPUParticles2D = $AccelerationParticles

var damage: float = 0
var speed: float = 0


func _physics_process(delta: float) -> void:
	var turn_dir: float = 0
	if Input.is_action_pressed("move_left"):
		turn_dir -= 1
	if Input.is_action_pressed("move_right"):
		turn_dir += 1
	rotation += turn_dir * rotation_speed * delta
	
	var accel: float = 0
	if Input.is_action_pressed("move_up"):
		accel += thrust
	if accel != 0:
		velocity += Vector2.UP.rotated(rotation) * accel * delta
		acceleration_particles.emitting = true
	else:
		acceleration_particles.emitting = false
	if Input.is_action_pressed("move_down"):
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	speed = velocity.length()
	move_and_slide()
	var collision_count = get_slide_collision_count()
	if collision_count > 0:
		handle_collisions()

func handle_collisions() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var push_direction = collision.get_normal() * -1
			var push_force = velocity.length() * collision_push_force
			var collision_point = collision.get_position()
			collider.apply_impulse(push_direction * push_force, collision_point - collider.global_position)
			velocity *= (1.0 - collision_damping)
			damage += (push_direction * push_force).length() * 0.05
			print(damage)
