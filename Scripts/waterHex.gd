extends MeshInstance3D

@export var new_tile_scene: PackedScene = preload("res://Scenes/forest_hex.tscn")
var shader_resource: Shader = preload("res://Assets/Shaders/water_animate.gdshader")
var shader_material: ShaderMaterial = ShaderMaterial.new()

func _ready() -> void:
	# Assign the shader to the ShaderMaterial.
	shader_material.shader = shader_resource
	# Set an initial color.
	shader_material.set_shader_parameter("albedo_color", Color(0.4, 0.8, 0.9, 1))
	# Give each tile a unique phase offset.
	shader_material.set_shader_parameter("phase_offset", randf_range(0, 2 * PI))
	# Assign the ShaderMaterial to the mesh.
	set_surface_override_material(0, shader_material)

func _on_area_3d_mouse_entered() -> void:
	_change_color(Color(1, 0.2, 0.3, 1))  # Change to red.
	_apply_to_neighbors("_change_color", Color(1, 0.2, 0.3, 1))  # Also update neighbors.

func _on_area_3d_mouse_exited() -> void:
	_change_color(Color(0.4, 0.8, 0.9, 1))  # Change back to blue.
	_apply_to_neighbors("_change_color", Color(0.4, 0.8, 0.9, 1))

func _on_area_3d_input_event(camera, event, position, normal, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_replace_tile()
		_apply_to_neighbors("_replace_tile")

func _change_color(color: Color):
	shader_material.set_shader_parameter("albedo_color", color)

func _replace_tile() -> void:
	if new_tile_scene:
		var new_tile = new_tile_scene.instantiate()
		new_tile.transform = self.transform  # Keep the same position.
		get_parent().add_child(new_tile)
		queue_free()  # Remove the old tile.

func _apply_to_neighbors(action: String, param = null):
	var parent_board = get_parent()
	if parent_board and parent_board.has_method("get_tile_at"):
		var coords = get_meta("hex_coords") as Vector2i

		# Axial hex coordinate offsets for right, left, and front neighbors.
		var neighbor_offsets = [
			Vector2(1, 0),  
			Vector2(-1, 0),
			Vector2(0, 1)
		]

		for offset in neighbor_offsets:
			var neighbor_coords = coords + offset
			var neighbor_tile = parent_board.get_tile_at(neighbor_coords)
			if neighbor_tile:
				print("Neighbor found at:", neighbor_coords)
				if neighbor_tile.has_method(action):
					if param != null:
						neighbor_tile.call(action, param)
					else:
						neighbor_tile.call(action)

func _process(delta: float) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	shader_material.set_shader_parameter("time", current_time)
