extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Time.text = "Your Time: " + str(GameManager.game_time)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/main_menu.tscn")
