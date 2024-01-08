extends Node3D

@export var gate_num_connected: int
@export var spawn_points: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.signal_open_gate.connect(on_open_gate)
	spawn_points = get_children()

func on_open_gate(gate_number: int):
	if gate_num_connected == gate_number:
		for sp in spawn_points:
			if sp.is_in_group("Spawnpoint"):
				sp.spawn()

