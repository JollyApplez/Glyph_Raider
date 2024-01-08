extends Node3D




func _on_victory_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		GameManager._on_victory()
