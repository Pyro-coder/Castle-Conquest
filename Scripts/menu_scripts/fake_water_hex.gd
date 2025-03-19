extends MeshInstance3D

var shader_resource: Shader = preload("res://Assets/Shaders/water_animate.gdshader")
var shader_material: ShaderMaterial = ShaderMaterial.new()
var coordsfromboard
var tileType = "water"

var board

func _ready() -> void:
	# Assign the shader to the ShaderMaterial.
	
	shader_material.shader = shader_resource
	# Set an initial color.
	shader_material.set_shader_parameter("albedo_color", Color(0.12, 0.28, 0.66, 1.0))
	# Give each tile a unique phase offset.
	shader_material.set_shader_parameter("phase_offset", randf_range(0, 2 * PI))
	# Assign the ShaderMaterial to the mesh.
	set_surface_override_material(0, shader_material)
	
	
	
func check(string):
	print(string)

func type():
	
	return tileType
	
func setType(string):
	tileType = string
	
func setcoords(vector):
	coordsfromboard = vector



func _process(delta: float) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	shader_material.set_shader_parameter("time", current_time)
