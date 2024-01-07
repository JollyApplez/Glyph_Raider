extends Node3D

@onready var ray: RayCast3D = $RayCast3D
var isColliding
var target
var isCarrying := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isCarrying and Input.is_action_just_pressed("pickup"):
		ray.enabled = true
		isCarrying = false
		target.idle()
		target = null

	if ray.is_colliding():
		isColliding = true
		target = ray.get_collider()
		if target.is_in_group("hb_cube"):
			target = target.get_parent()
			target.interactable()
			if Input.is_action_just_pressed("pickup"):
				print("cube: pickup state")
				ray.enabled = false
				isCarrying = true

	if isCarrying:
		target.carried($CSGBox3D.global_position)

