extends Control

@onready var settings_menu: Control = $"../SettingsMenu"

func _on_play_pressed() -> void:
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_settings_pressed() -> void:
	settings_menu.pause_menu = true
	settings_menu.visible = true
	visible = false

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Game/main_menu.tscn")
