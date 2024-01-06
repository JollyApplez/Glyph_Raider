extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ENEMY_BULLET = preload("res://Enemies/EnemyBullet.tscn")


@export var health := 30
@export var attack_range := 1.5
@export var grounded = false
@export var aggro_range: float = 12.0
@export var isRanged: bool = true
@export var attack_speed := 1.5


var bullet
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var player: CharacterBody3D
var provoked := false

@onready var barrel: Node3D = %Barrel
@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var attack_timer: Timer = $AttackTimer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	bullet = ENEMY_BULLET
	
	if grounded: 
		motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
func _process(_delta: float) -> void:
	if provoked:
		navigation_agent_3d.target_position = player.global_position
	
	if !grounded:
		$Navigation.global_position.y = global_position.y - global_position.y
func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor() and grounded:
		velocity.y -= gravity * delta
	
	var distance = global_position.distance_to(player.global_position)

	if distance <= aggro_range:
		provoked = true
		
	else: 
		provoked = false

	if provoked: 
		var next_positon = navigation_agent_3d.get_next_path_position()
		var direction = global_position.direction_to(next_positon)
		
		if direction:
			look_at_target(direction)

			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if distance >= attack_range:
		move_and_slide()
	else: 
		if attack_timer.is_stopped():
			attack_timer.start(attack_speed)
			if isRanged:
				ranged_attack()
			else: 
				attack()

func look_at_target(direction: Vector3):
	var adjusted_direction = direction
	adjusted_direction.y = 0
	
	look_at(global_position + adjusted_direction, Vector3.UP, false)
	barrel.look_at(player.global_position, Vector3.UP, false)
	
func ranged_attack():
	var b = bullet.instantiate()
	b.position = barrel.global_position
	b.transform.basis = barrel.global_transform.basis
	get_parent().add_child(b)
	

func attack():
	pass
	
func _on_hitbox_body_part_hit(dam: Variant) -> void:
	health -= dam
	if health <= 0:
		die()
func die():
	queue_free()
