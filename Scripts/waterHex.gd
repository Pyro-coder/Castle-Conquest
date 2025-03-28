extends MeshInstance3D

@export var new_tile_scene: PackedScene = preload("res://Scenes/forest_hex.tscn")
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


func _on_static_body_3d_mouse_entered() -> void:
	# Only allow placing tiles in the tile placement phase, and when it is the current user's turn
	if (board.control_node.game_state == board.control_node.GameState.TILE_PLACEMENT && GlobalVars.player_turn or (board.control_node.game_state == board.control_node.GameState.TILE_PLACEMENT and GlobalVars.is_local_pvp)):
		if type() == "water":
			board.OnBoardPlaceHover(coordsfromboard,Color(0.8, 0.1, 0.1, 1.0))
			#_change_color(Color(0.8, 0.1, 0.1, 1.0))  # Change to red.
			_apply_to_neighbors("_change_color", Color(0.12, 0.28, 0.66, 1.0))  # Also update neighbors.
	elif board.control_node.game_state == board.control_node.GameState.INITIAL_PLACEMENT and GlobalVars.player_turn:
		_change_color("red")
	

func _on_static_body_3d_mouse_exited() -> void:
	var control = board.control_node
	
	# Only allow placing tiles in the tile placement phase, and when it is the current user's turn
	if control.game_state == control.GameState.TILE_PLACEMENT and GlobalVars.player_turn or (board.control_node.game_state == board.control_node.GameState.TILE_PLACEMENT and GlobalVars.is_local_pvp):
		_apply_to_neighbors("_change_color", Color(0.12, 0.28, 0.66, 1.0))
		board.OnBoardPlaceHoverExit(coordsfromboard,Color(0.12, 0.28, 0.66, 1.0))
		#_change_color(Color(0.12, 0.28, 0.66, 1.0))  # Change back to blue.
		
		
	else:
		_change_color(Color(0.12, 0.28, 0.66, 1.0))

func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if Input.is_action_pressed("ui_click"):
		GlobalVars.castle_selected = false
		GlobalVars.valid_move_tiles = []
		GlobalVars.hex_selected = coordsfromboard
		
	_on_static_body_3d_mouse_entered()
	# Only allow placing tiles in the tile placement phase, and when it is the current user's turn
	if (board.control_node.game_state == board.control_node.GameState.TILE_PLACEMENT && GlobalVars.player_turn or (board.control_node.game_state == board.control_node.GameState.TILE_PLACEMENT and GlobalVars.is_local_pvp)):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			board.OnBoardPlaceClick(coordsfromboard)
			
			# These lines fix a bug where tiles wont update after the initial placement as player 1, and where green remains after first placement by player
			var current_color = shader_material.get_shader_parameter("albedo_color")
			if board.control_node.tile_round == 1 and board.control_node.turn_order[0].Id == 1 or current_color != Color(0.8, 0.1, 0.1, 1.0):
				board.OnBoardPlaceHoverExit(coordsfromboard,Color(0.12, 0.28, 0.66, 1.0))
				_apply_to_neighbors("_change_color", Color(0.12, 0.28, 0.66, 1.0))

func _change_color(color: Color):
	shader_material.set_shader_parameter("albedo_color", color)

func _replace_tile() -> void:
	if new_tile_scene:
		var new_tile = new_tile_scene.instantiate()
		new_tile.transform = self.transform  # Keep the same position.
		new_tile.get_child(0).setcoords(coordsfromboard)
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
