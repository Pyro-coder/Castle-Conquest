extends Control

@onready var blueSprite = $Goldwood/AnimatedSprite2D
@onready var redSprite = $Goldwood2/AnimatedSprite2D
@onready var message_label = $MessageContainer/messageBoard
var blue_shader: ShaderMaterial
var red_shader: ShaderMaterial


@onready var wait_timer = $messageTimer
# @onready var message_label = $message_label
var messageNum = 1
var phaseNum = 1
var isBlueTurn: bool
var glow_power = 2.0
var glow_shift = 1.0
var glowradius = 1.0
var noshift = 0.0
var noradius = 0.0
var noglow = 0.0

var shaderMaterial : ShaderMaterial

var is_first_move= true
var isP1Turn = GlobalVars.first_player_moves_first
func _ready() -> void:
	wait_timer.start()
	
	var glow_shader_source = load("res://Scenes/Menus/glow.gdshader")
	blue_shader = ShaderMaterial.new()
	red_shader = ShaderMaterial.new()

	blue_shader.shader = glow_shader_source
	red_shader.shader = glow_shader_source

	blueSprite.material = blue_shader
	redSprite.material = red_shader
	updateShaderVisibility()
	if GlobalVars.first_player_moves_first:
		P2TurnCompleteAnimation()
	else:
		P1TurnCompleteAnimation()

func update_phase_num(phaseNumFromBoard):
	phaseNum = phaseNumFromBoard

func updateShaderVisibility() -> void:
	if isBlueTurn:
		blue_shader.set_shader_parameter("glow_power", glow_power)
		blue_shader.set_shader_parameter("glow_shift", glow_shift)
		blue_shader.set_shader_parameter("glow_radius", glowradius)
		red_shader.set_shader_parameter("glow_power", noglow)
		red_shader.set_shader_parameter("glow_shift", noshift)
		red_shader.set_shader_parameter("glow_radius", noradius)
	else:
		blue_shader.set_shader_parameter("glow_power", noglow)
		blue_shader.set_shader_parameter("glow_shift", noshift)
		blue_shader.set_shader_parameter("glow_radius", noradius)
		red_shader.set_shader_parameter("glow_power", glow_power)
		red_shader.set_shader_parameter("glow_shift", glow_shift)
		red_shader.set_shader_parameter("glow_radius", glowradius)


func erase_blue_hex(hex_count):
	
	$BlueHexContainer.get_child(hex_count).visible = false
	
func erase_red_hex(hex_count):
	$RedHexContainer.get_child(hex_count).visible = false
	
func P1LoseAnimation():
	blueSprite.play("death")

func P1TurnCompleteAnimation():
	
	$Goldwood2/redPanelContainer.visible = false
	$Goldwood/bluePanelContainer.visible = true
	if is_first_move:
		is_first_move = false
	else:
		blueSprite.play("attack")
	redSprite.play("idle")
	
	isBlueTurn = false
	updateShaderVisibility()
	
	
func P2LoseAnimation():
	redSprite.play("death")
	
func P2TurnCompleteAnimation():
	
	$Goldwood2/redPanelContainer.visible = true
	$Goldwood/bluePanelContainer.visible = false
	if is_first_move:
		is_first_move = false
	else:
		redSprite.play("attack")
	blueSprite.play("idle")

	isBlueTurn = true
	updateShaderVisibility()


func UpdateMainLabel(textInput):
	var Main_Banner = $"Banners-large-cropped-main/MainLabel"
	Main_Banner.text = textInput
	

func UpdateP1Label(input):
	var P1Label = $BlueWood/blueLabel
	P1Label.text = input
	
func UpdateP2Label(input):
	var P2Label = $RedWood/redLabel
	P2Label.text = input
	

	

func animation_finished() -> void:
	if redSprite.animation == "attack":
		redSprite.play("idle")
	elif blueSprite.animation == "attack":
		blueSprite.play("idle")


func _on_message_timer_timeout() -> void:
	message_label.add_theme_font_size_override("font_size",20)
	
	if phaseNum == 1:
		
		if messageNum == 1:
	
			message_label.text = "Hint: [Space] To Rotate Board Pieces"
			messageNum = 2
		elif messageNum == 2:
			message_label.text = "Hint: Green Tiles Are Valid Placements"
			messageNum = 3

		elif messageNum == 3: 
			messageNum = 4
			message_label.text = "Hint: Left Click To Place Board Pieces"
			
		elif messageNum == 4:
			messageNum = 1
			message_label.text = "Hint: Arrow Keys Move The Camera"
			
		
			
	elif phaseNum == 2:
		if messageNum == 1:
			message_label.text = "Hint: Place Castle At Board’s Edge"
			messageNum = 2
		elif messageNum == 2:
			message_label.text = "Hint: Green Tiles Are Valid Placements"
			messageNum = 3
			 
		elif messageNum == 3: 
			messageNum = 4
			message_label.text = "Hint: Left Click To Place Castle"
			
		elif messageNum == 4:
			messageNum = 1
			message_label.text = "Hint: Arrow Keys Move The Camera"
			
		
	elif phaseNum == 3:
		if messageNum == 1:
			message_label.text = "Hint: Left Click To Select Buildings"
			messageNum = 2
		elif messageNum == 2:
			message_label.add_theme_font_size_override("font_size",15)
			message_label.text = "Hint: Use Slider To Select Number Tokens To Move"
			messageNum = 3
			 
		elif messageNum == 3: 
			messageNum = 4
			message_label.text = "Hint: Left Click To Move Buildings"
			
		elif messageNum == 4:
			messageNum = 1
			message_label.text = "Hint: Arrow Keys Move The Camera"
			
	wait_timer.start()
	

func _on_timer_timeout() -> void:
	pass
	




func _on_question_button_pressed() -> void:
	$QuestionMark.visible = false
	$MessageContainer.visible = true
	$BackArrow.visible = true
	



func _on_back_arrow_pressed() -> void:
	$QuestionMark.visible = true
	$MessageContainer.visible = false
	$BackArrow.visible = false


func _on_question_button_mouse_entered() -> void:

	$QuestionMark.modulate = Color(1.1, 1.1, 1.1) # Slightly brighten the button
	$QuestionMark.scale = Vector2(1.01, 1.01)


func _on_question_button_mouse_exited() -> void:

	$QuestionMark.modulate = Color(1, 1, 1) # Slightly brighten the button
	$QuestionMark.scale = Vector2(.99, .99)


func _on_back_arrow_mouse_entered() -> void:
	$BackArrow.modulate = Color(1.1, 1.1, 1.1) # Slightly brighten the button
	$BackArrow.scale = Vector2(1.01, 1.01)


func _on_back_arrow_mouse_exited() -> void:
	$BackArrow.modulate = Color(1, 1, 1) # Slightly brighten the button
	$BackArrow.scale = Vector2(.99, .99)
