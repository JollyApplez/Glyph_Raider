extends Node3D

var have_triggered: bool
var spawn_points: Array

func _ready() -> void:
	spawn_points = get_children()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and !have_triggered:
		have_triggered = true
		for sp in spawn_points:
			if sp.is_in_group("Spawnpoint"):
				sp.spawn()
