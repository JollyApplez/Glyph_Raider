extends CharacterBody3D

const RUN_SPEED := 10.0
const DASH_SPEED_GROUND := 30.0
const DASH_SPEED_AIR := 25.0
const JUMP_VELOCITY := 12
const GRAVITY_MULT := 2.8
const DAMPENING_GROUND := 0.6
const DAMPENING_AIR := 0.025
#BOB variables
const BOB_FREQ := 2.0
const BOB_AMP := 0.08
#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@export var sensitivity := 0.004
@export var max_ammo: int = 30
@export var max_health: int = 100
@export var reload_speed := 1.0
@export var attack_speed := 0.2

var health
var ammo
var jump_count := 0
var speed 
var t_bob := 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var has_dashed := false
var dash_timer_running := false
var hit_shake_period := 0.1
var hit_shake_magnitude := 0.15
var can_shoot = true

var bullet = preload("res://Player/bullet.tscn")

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var barrel = $Head/Camera3D/Gun/RayCast3D
@onready var reload_speed_timer: Timer = $Head/Camera3D/Gun/ReloadSpeed
@onready var attack_speed_timer: Timer = $Head/Camera3D/Gun/AttackSpeed
@onready var auto_reload_speed: Timer = $Head/Camera3D/Gun/AutoReloadSpeed
@onready var step_timer: Timer = $StepTimer
@onready var step_sound: AudioStreamPlayer3D = $StepTimer/StepSound

func _ready() -> void:
	speed = RUN_SPEED
	health = max_health
	ammo = max_ammo

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_on_floor():
		jump_count = 0
	else:
		velocity.y -= gravity * GRAVITY_MULT * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jump_count <= 1:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		speed = RUN_SPEED # Remove for super jump with dash + jump
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#and is_on_floor()
	if Input.is_action_just_pressed("dash") and !has_dashed:
		_dash_manager()
	
	if velocity.x != 0 or velocity.z != 0:
		if step_timer.is_stopped():
			step_timer.start()
	
	# Apply linear speed on x and z
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, DAMPENING_GROUND)
			velocity.z = move_toward(velocity.z, 0, DAMPENING_GROUND)
	# Apply Dampening in air
	else: 
		if step_sound.playing: 
				step_sound.stop()
		if dash_timer_running:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else: 
			velocity.x = move_toward(velocity.x, 0, DAMPENING_AIR)
			velocity.z = move_toward(velocity.z, 0, DAMPENING_AIR)
	
	_head_bob(delta)
	_fov_manager(delta)
	move_and_slide()
	
	if Input.is_action_pressed("shoot") and reload_speed_timer.is_stopped() and attack_speed_timer.is_stopped():
		_shooting()
	if Input.is_action_just_pressed("reload"):
		reload_speed_timer.start(reload_speed)

func _shooting() -> void:
	if can_shoot:
		attack_speed_timer.start(attack_speed)
		
		ammo -= 1
		var b = bullet.instantiate()
		b.position = barrel.global_position
		b.transform.basis = barrel.global_transform.basis
		get_parent().add_child(b)
		$Head/Camera3D/Gun/LaserSound. play()

func _head_bob(delta: float) -> void:
	if is_on_floor():
		t_bob += delta * velocity.length() / 2 
		camera.transform.origin = _headbob_time(t_bob)

func _headbob_time(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _dash_manager() -> void:
	
	var dash_time: float
	if is_on_floor():
		speed = DASH_SPEED_GROUND
		dash_time = 0.25
		
	else: 
		speed = DASH_SPEED_AIR
		dash_time = 0.10
	
	has_dashed = true
	
	var dash_timer = Timer.new()
	add_child(dash_timer)
	dash_timer.timeout.connect(_dash_timeout)
	dash_timer.one_shot = true
	dash_timer.start(dash_time)
	
	dash_timer_running = true
	
	var dash_cooldown_timer = Timer.new()
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.timeout.connect(_dash_cooldown_timeout)
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.start(1)

func _dash_timeout() -> void:
	speed = RUN_SPEED
	dash_timer_running = false

func _dash_cooldown_timeout() -> void:
	has_dashed = false

func _fov_manager(delta) -> void:
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, DASH_SPEED_GROUND * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func die():
	get_tree().change_scene_to_file("res://Game/main_menu.tscn")

func _on_player_hitbox_body_part_hit(dam: Variant) -> void:
	camera._camera_shake(hit_shake_period, hit_shake_magnitude)
	
	health -= dam
	print_debug(health)
	if health <= 0:
		die()

func _on_auto_reload_speed_timeout() -> void:
	auto_reload_speed.start()
	ammo += 1

func _on_reload_speed_timeout() -> void:
	if ammo < max_ammo:
		ammo = max_ammo


func _on_step_timer_timeout() -> void:
	$StepTimer/StepSound.play()
