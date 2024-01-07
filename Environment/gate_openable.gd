extends Node3D

@export var gate_identifier_num: int

func _ready() -> void:
	SceneManager.signal_open_gate.connect(on_open_gate)

func on_open_gate(gate_number: int):
	if gate_identifier_num == gate_number:
		$AnimationPlayer.play("Open")
