extends Node3D



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	
	#Quitting the game with Esc
	if event.is_action_pressed("quit"):
		get_tree().quit()
	
	if event.is_action_pressed("interact"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _unhandled_input(event: InputEvent) -> void:
	pass
	

func disable_mouse_cursor():
	pass
