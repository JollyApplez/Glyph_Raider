extends Control

@onready var master_volume_slider: HSlider = $VBoxContainer/VolumeSlider
var pause_menu = false

var bus_index: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus_index = AudioServer.get_bus_index("Master")
	#master_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	AudioServer.set_bus_volume_db(
	bus_index,
	linear_to_db(0.1)
	)
func _process(delta: float) -> void:
	#Sensitivity Slider
	$VBoxContainer/SensValueLabel.text = "Current: " + str($VBoxContainer/SenseSlider.value)
	
	#Master Audio Slider
	$VBoxContainer/VolumeValueLabel.text = "Current: " + str($VBoxContainer/VolumeSlider.value)
	

func _on_volume_slider_value_changed(value: float) -> void:
	print("Changed")
	
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)



func _on_sense_slider_value_changed(value: float) -> void:
	GameManager.player_sensitivity = value / 100
	print(GameManager.player_sensitivity)


func _on_button_pressed() -> void:
	if pause_menu:
		hide()
		get_tree().get_first_node_in_group("PauseMenu").show()
	else: 
		hide()
		get_tree().get_first_node_in_group("MainMenu").show()


func _on_button_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
