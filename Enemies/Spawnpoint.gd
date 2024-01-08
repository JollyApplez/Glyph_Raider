extends Node3D

@export var enemy_to_spawn: PackedScene

func spawn():
	$AudioStreamPlayer3D.play()
	var e = enemy_to_spawn.instantiate()
	get_parent().add_child(e)
	e.global_position = global_position
	
	#Spawn Indicator and sound happens here
