extends Node3D

@export var  SPEED := 20.0
@export var damage := 10

@onready var mesh = $MeshInstance3D
@onready var ray = $MeshInstance3D/RayCast3D
@onready var hit_particles: GPUParticles3D = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		ray.enabled = false
		mesh.visible = false
		hit_particles.emitting = true
		var target = ray.get_collider()
		if target.is_in_group("Player_HB"):
			target.hit(damage)
		await get_tree().create_timer(.6).timeout
		queue_free()


func _on_life_timer_timeout() -> void:
	queue_free()
