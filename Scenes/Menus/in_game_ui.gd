extends Control

@onready var pauseBtn = $TextureButton

func _ready() -> void:
	if pauseBtn:
		pauseBtn.connect("mouse_entered", pauseHvrd)
		pauseBtn.connect("mouse_exited", pauseExt)
		

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
