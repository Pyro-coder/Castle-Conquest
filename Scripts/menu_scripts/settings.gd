extends Control

@onready var backBtn = $MenuTemplate/HBoxContainer/BackButton
@onready var applyBtn = $MenuTemplate/HBoxContainer/ApplyButton
@onready var musicSlider = $MenuTemplate/VBoxContainer/Label2/MusicSlider

var music_volume = 1.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if backBtn:
		backBtn.connect("mouse_entered", backBtnHvrd)
		backBtn.connect("mouse_exited", backBtnExt)
	if applyBtn:
		applyBtn.connect("mouse_entered", applyHvrd)
		applyBtn.connect("mouse_exited", applyExt)
	if musicSlider:
		musicSlider.value = loadMusicVolume()
		music_volume = musicSlider.value
		musicSlider.connect("value_changed", musicSliderValueChanged)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func musicSliderValueChanged(value: float) -> void:
	music_volume = value
	if has_node("/root/AudioPlayer"):
		var audio_player = get_node("/root/AudioPlayer")
		audio_player.volume_db = linear_to_db(music_volume)
	
func _on_apply_button_pressed() -> void:
	saveMusicVolume(music_volume)
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func backBtnHvrd() -> void:
	if backBtn:
		backBtn.scale = Vector2(1.1, 1.1)

func backBtnExt() -> void:
	if backBtn:
		backBtn.scale = Vector2(1, 1)
		
func applyHvrd() -> void:
	if applyBtn:
		applyBtn.scale = Vector2(1.1, 1.1)

func applyExt() -> void: 
	if applyBtn:
		applyBtn.scale = Vector2(1, 1)

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func saveMusicVolume(volume: float) -> void:
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("audio", "music_volume", volume)
	config.save("user://settings.cfg")
	
func loadMusicVolume() -> float:
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	if config.has_section_key("audio", "music_volume"):
		return config.get_value("audio", "music_volume")
	else:
		return 1.0
	
 
	
