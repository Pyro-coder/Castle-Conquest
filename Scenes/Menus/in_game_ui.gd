extends Control


@onready var blueSprite = $Goldwood/AnimatedSprite2D
@onready var redSprite = $Goldwood2/AnimatedSprite2D

var blue_shader: ShaderMaterial
var red_shader: ShaderMaterial


var isBlueTurn: bool
var glow_power = 2.0
var glow_shift = 1.0
var glowradius = 1.0
var noshift = 0.0
var noradius = 0.0
var noglow = 0.0

var shaderMaterial : ShaderMaterial

func _ready() -> void:
	
		
	var glow_shader_source = load("res://Scenes/Menus/glow.gdshader")
	blue_shader = ShaderMaterial.new()
	red_shader = ShaderMaterial.new()

	blue_shader.shader = glow_shader_source
	red_shader.shader = glow_shader_source

	blueSprite.material = blue_shader
	redSprite.material = red_shader
	updateShaderVisibility()

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
	blueSprite.play("attack")
	isBlueTurn = false
	updateShaderVisibility()
	
	
func P2LoseAnimation():
	redSprite.play("death")
	
func P2TurnCompleteAnimation():
	redSprite.play("attack")
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
