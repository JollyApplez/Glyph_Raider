extends RigidBody3D


var isCarried := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	idle()

func idle():
	animation_player.play("RESET")
	animation_player.play("idle")
	isCarried = false

func interactable():
	animation_player.play("Interactable")
	
func carried(pos: Vector3):
	isCarried = true
	animation_player.play("Carried")
	global_position = pos
