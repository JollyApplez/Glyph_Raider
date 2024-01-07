extends Control

@onready var master_volume_slider: HSlider = $VBoxContainer/VolumeSlider

var bus_index: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus_index = AudioServer.get_bus_index("Master")
	master_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
