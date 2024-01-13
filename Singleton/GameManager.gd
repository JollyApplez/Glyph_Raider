extends Node

var game_time: float
var game_is_started = false
var player_sensitivity: float


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if game_is_started:
		game_time += delta

func _on_victory(): 
	game_is_started = false
	game_time = int(game_time)
	get_tree().change_scene_to_file("res://Game/victory.tscn")
