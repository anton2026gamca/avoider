extends Area2D
class_name Bullet


@export var velocity: Vector2 = Vector2.ZERO

@onready var cpu_particles_2d: GPUParticles2D = $CPUParticles2D


func _ready() -> void:
	cpu_particles_2d.restart()
	cpu_particles_2d.finished.connect(destroy)

func _process(delta: float) -> void:
	position += velocity * delta


func destroy() -> void:
	get_parent().remove_child(self)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Meteoroid:
		body.destroy()
