extends Node3D

@export var gate_identifier_num: int
@export var room_identifier_num: int
@export var req_key_amount: int

var current_key_amount: int

func _ready() -> void:
	SceneManager.signal_open_gate.connect(on_open_gate)
	SceneManager.signal_register_key.connect(on_key_register)

func on_open_gate(gate_number: int):
	if gate_identifier_num == gate_number:
		$AnimationPlayer.play("Open")

func on_key_register(room_number: int, gate_number: int):
	if gate_identifier_num == gate_number and room_number == room_identifier_num:
		current_key_amount += 1
	
		if current_key_amount == req_key_amount:
			SceneManager.signal_open_gate.emit(gate_identifier_num)
