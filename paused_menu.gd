extends Control

@onready var resumeBtn = $GridContainer/ResumeBtn
@onready var settingsBtn = $GridContainer/SettingsBtn
@onready var quitBtn = $GridContainer/QuitBtn
@onready var mainBtn = $GridContainer2/Back2MainBtn

var _is_paused:bool = false:
	set = set_paused
	
func _ready() -> void:
	if resumeBtn:
		resumeBtn.connect("mouse_entered", resumeBtnHvrd)
		resumeBtn.connect("mouse_exited", resumeBtnExt)
	if settingsBtn:
		settingsBtn.connect("mouse_entered", settingsBtnHvrd)
		settingsBtn.connect("mouse_exited", settingsBtnExt)
	if quitBtn:
		quitBtn.connect("mouse_entered", quitBtnHvrd)
		quitBtn.connect("mouse_exited", quitBtnExt)
	if mainBtn:
		mainBtn.connect("mouse_entered", mainHvrd)
		mainBtn.connect("mouse_exited", mainExt)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_paused(!_is_paused)
		
func click_unhandled_input(event: InputEvent) -> void:
	if event.is_action("mouseclick"):
		set_paused(!_is_paused)
	
func set_paused(value:bool) ->void:
	visible = _is_paused
	_is_paused = value
	get_tree().paused = _is_paused

func _on_resume_btn_pressed() -> void:
	set_paused(false)

func _on_settings_btn_pressed() -> void:
	pass # Replace with function body.

func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _on_back_2_main_btn_pressed() -> void:
	set_paused(false)
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	
	
func resumeBtnHvrd() -> void:
	if resumeBtn:
		resumeBtn.scale = Vector2(1.1, 1.1)
		
func resumeBtnExt() -> void:
	if resumeBtn:
		resumeBtn.scale = Vector2(1, 1)
		
func settingsBtnHvrd() -> void:
	if settingsBtn:
		settingsBtn.scale = Vector2(1.1, 1.1)

func settingsBtnExt() -> void:
	if settingsBtn:
		settingsBtn.scale = Vector2(1, 1)		
		
func quitBtnHvrd() -> void: 
	if quitBtn:
		quitBtn.scale = Vector2(1.1, 1.1)

func quitBtnExt() -> void:
	if quitBtn:
		quitBtn.scale = Vector2(1, 1)
		
func mainHvrd() -> void:
	if mainBtn:
		mainBtn.scale = Vector2(1.1, 1.1)

func mainExt() -> void:
	if mainBtn:
		mainBtn.scale = Vector2(1, 1)
