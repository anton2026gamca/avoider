extends Area2D
class_name Bullet


@export var velocity: Vector2 = Vector2.ZERO

@onready var gpu_particles: GPUParticles2D = $GPUParticles2D

var time: float = 0
var max_distance: float = 150.0
var distance_tolerance: float = 8

func _ready() -> void:
	gpu_particles.restart()
	gpu_particles.finished.connect(destroy)

func _process(delta: float) -> void:
	time += delta
	position += velocity * delta
	for body: Node2D in get_overlapping_bodies():
		if body is Meteoroid:
			var dist: float = global_position.distance_to(body.global_position)
			if (dist - distance_tolerance + body.radius) / max_distance > time / gpu_particles.lifetime and \
			   (dist + distance_tolerance - body.radius) / max_distance < time / gpu_particles.lifetime:
				body.destroy()


func destroy() -> void:
	get_parent().remove_child(self)
	queue_free()
