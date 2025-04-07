extends Control

@onready var pauseBtn = $TextureButton
@onready var pauseMenu = $CanvasLayer/PausedMenu
@onready var resumeBtn = $CanvasLayer/PausedMenu/GridContainer/ResumeBtn
@onready var blueSprite = $Goldwood/AnimatedSprite2D
@onready var redSprite = $Goldwood2/AnimatedSprite2D
var _is_paused: bool = false:
	set = set_paused

func _ready() -> void:
	if pauseBtn:
		pauseBtn.connect("mouse_entered", pauseHvrd)
		pauseBtn.connect("mouse_exited", pauseExt)
		pauseBtn.connect("pressed", _on_texture_button_pressed)
	if pauseMenu:
		pauseMenu.visible = false
	if resumeBtn:
		resumeBtn.connect("pressed", _on_resume_btn_pressed)
		



func erase_blue_hex(hex_count):
	
	$BlueHexContainer.get_child(hex_count).visible = false
	
func erase_red_hex(hex_count):
	$RedHexContainer.get_child(hex_count).visible = false
	
func P1LoseAnimation():
	blueSprite.play("death")

func P1TurnCompleteAnimation():
	blueSprite.play("attack")
	
	
func P2LoseAnimation():
	redSprite.play("death")
	
func P2TurnCompleteAnimation():
	redSprite.play("attack")


func UpdateMainLabel(textInput):
	var Main_Banner = $"Banners-large-cropped-main/MainLabel"
	Main_Banner.text = textInput
	

func UpdateP1Label(input):
	var P1Label = $BlueWood/blueLabel
	P1Label.text = input
	
func UpdateP2Label(input):
	var P2Label = $RedWood/redLabel
	P2Label.text = input
	
func pauseHvrd() -> void:
	if pauseBtn: 
		pauseBtn.modulate = Color(1.2, 1.2, 1.2)
		pauseBtn.scale = Vector2(.23, .23)
		
func pauseExt() -> void:
	if pauseBtn:
		pauseBtn.modulate = Color(1, 1, 1)
		pauseBtn.scale = Vector2(.2, .2)
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	_is_paused = !_is_paused
	set_paused(_is_paused)
		
func set_paused(value: bool) -> void:
	_is_paused = value
	get_tree().paused = _is_paused
	pauseMenu.visible = _is_paused

func _on_resume_btn_pressed() -> void:
	toggle_pause()
	
func _on_settings_btn_pressed() -> void:
	pass # Replace with function body.

func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _on_back_2_main_btn_pressed() -> void:
	toggle_pause()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _on_texture_button_pressed() -> void:
	toggle_pause()
	


func animation_finished() -> void:
	if redSprite.animation == "attack":
		redSprite.play("idle")
	elif blueSprite.animation == "attack":
		blueSprite.play("idle")
