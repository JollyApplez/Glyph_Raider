extends Area3D

@export var room_num := 0
@export var connected_gate_num := 0
@onready var activated_light: SpotLight3D = $ActivatedLight


func _on_area_entered(area: Area3D) -> void:
		if area.is_in_group("hb_cube"):
			SceneManager.signal_register_key.emit(room_num, connected_gate_num)
			print("cube")
			activated_light.show()



func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("hb_cube"):
			SceneManager.signal_register_key.emit(room_num, connected_gate_num)
			print("cube")
			activated_light.hide()

