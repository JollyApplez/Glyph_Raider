extends CharacterBody3D

const RUN_SPEED := 10.0
const DASH_SPEED := 30.0
const JUMP_VELOCITY := 12
const GRAVITY_MULT := 2.8
const DAMPENING_GROUND := 0.6
const DAMPENING_AIR := 0.025
const BOB_FREQ := 2.0
const BOB_AMP := 0.08

@export var sensitivity := 0.01
var speed 
var t_bob := 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var has_dashed = false

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready() -> void:
	speed = RUN_SPEED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if not is_on_floor():
		velocity.y -= gravity * GRAVITY_MULT * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_just_pressed("dash") and is_on_floor() and !has_dashed:
		_dash_manager()
	
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
		velocity.x = move_toward(velocity.x, 0, DAMPENING_AIR)
		velocity.z = move_toward(velocity.z, 0, DAMPENING_AIR)
	
	_head_bob(delta)
	
	move_and_slide()

func _head_bob(delta: float):
	if is_on_floor():
		t_bob += delta * velocity.length() / 2 
		camera.transform.origin = _headbob_time(t_bob)

func _headbob_time(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _dash_manager():
	speed = DASH_SPEED
		
	has_dashed = true
	
	var dash_timer = Timer.new()
	add_child(dash_timer)
	dash_timer.timeout.connect(_dash_timeout)
	dash_timer.one_shot = true
	dash_timer.start(0.25)
	
	var dash_cooldown_timer = Timer.new()
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.timeout.connect(_dash_cooldown_timeout)
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.start(1)

func _dash_timeout():
	speed = RUN_SPEED
	print(speed)

func _dash_cooldown_timeout():
	has_dashed = false