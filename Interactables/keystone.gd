extends RigidBody3D


var isCarried := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	idle()

func idle():
	animation_player.play("idle")
	isCarried = false

func interactable():
	animation_player.play("interactable")
	
func carried(position: Vector3):
	isCarried = true
	animation_player.play("carried")
	global_position = position
