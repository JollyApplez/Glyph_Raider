extends Node3D



@onready var ammo_label: Label = $Control/MarginContainer/AmmoLabel
@onready var health_label: Label = $Control/MarginContainer/HealthLabel
@onready var timer_label: Label = $Control/MarginContainer/TimerLabel

var player:CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#update health
	health_label.text = "Health: " + str(player.health) + "/ " + str(player.max_health)
	
	#update ammo
	ammo_label.text = str(player.ammo) + "/ " + str(player.max_ammo)
	
	var time = int(GameManager.game_time)
	timer_label.text = str(time)
