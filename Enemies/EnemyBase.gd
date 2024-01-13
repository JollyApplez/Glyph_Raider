extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ENEMY_BULLET = preload("res://Enemies/EnemyBullet.tscn")


@export var health := 30
@export var attack_range := 1.5
@export var grounded = false
@export var aggro_range: float = 12.0
@export var isRanged: bool = true
@export var isFlying: bool = true
@export var attack_speed := 1.5

var isShooting := false
var bullet
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var player: CharacterBody3D
var provoked := false

@onready var laser_sound: AudioStreamPlayer3D = $Weapon/LaserSound
@onready var barrel: Node3D = $Weapon/Barrel
@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_player: AnimationPlayer = $Alien_anim/AnimationPlayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	bullet = ENEMY_BULLET
	if isRanged:
		animation_player.play("ranged_idle")
		
	
	if grounded: 
		motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		

func _process(_delta: float) -> void:
	if provoked:
		navigation_agent_3d.target_position = player.global_position
	
	if !grounded:
		$Navigation.global_position.y = 0
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
		look_at_target()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			if isRanged && !isShooting:
				animation_player.play("ranged_running")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		animation_player.play("ranged_idle")
	
	if distance >= attack_range:
		move_and_slide()
		
	else: 
		if attack_timer.is_stopped():
			attack_timer.start(attack_speed)
			if isRanged:
				ranged_attack()
				
				
			else: 
				attack()
			laser_sound.play()

func look_at_target():
	var adjusted_direction = player.global_position
	adjusted_direction.y = 0
	
	look_at(adjusted_direction, Vector3.UP, false)
	barrel.look_at(player.global_position, Vector3.UP, false)
	
func ranged_attack():
	var b = bullet.instantiate()
	get_parent().add_child(b)
	b.global_position = barrel.global_position
	b.global_transform.basis = barrel.global_transform.basis
	b = null
	isShooting = true
	if velocity != Vector3.ZERO:
		animation_player.play("running_shooting")
	else:
		animation_player.play("standing_shooting")
	

func attack():
	pass
	
func _on_hitbox_body_part_hit(dam: Variant) -> void:
	health -= dam
	if health <= 0:
		die()
func die():
	queue_free()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "running_shooting" or anim_name == "standing_shooting":
		isShooting = false
