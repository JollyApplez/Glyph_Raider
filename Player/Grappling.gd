extends Node3D

@onready var ray: RayCast3D = $RayCast3D
var isColliding
var temp_target
var target
var isCarrying := false
@onready var gun: Node3D = $"../Gun"
@onready var player: CharacterBody3D = $"../../.."

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
		gun.show()
		player.can_shoot = true

	if ray.is_colliding():
		isColliding = true
		temp_target = ray.get_collider()
		if temp_target.is_in_group("hb_cube"):
			target = temp_target.get_parent()
			target.interactable()
			if Input.is_action_just_pressed("pickup"):
				print("cube: pickup state")
				ray.enabled = false
				isCarrying = true
				gun.hide()
				player.can_shoot = false
	else:
		if target != null and !isCarrying:
			target.idle()
			target = null

	if isCarrying:
		target.carried($CSGBox3D.global_position)
