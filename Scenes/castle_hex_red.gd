extends Node3D

var coordsfromboard: Vector2i

func setcoords(vector):
	coordsfromboard = vector

func _ready() -> void:
	add_to_group("Pieces")

func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# Only respond to clicks when it's not the current player's turn.
	if Input.is_action_pressed("ui_click") and !GlobalVars.player_turn and GlobalVars.is_local_pvp or Input.is_action_pressed("ui_click") and GlobalVars.player_turn and !GlobalVars.is_host:
		if self.get_child(0).name == "BuildingSmallhouseRed":
			return
		GlobalVars.hex_selected = coordsfromboard
		
		var child_node = self.get_child(0) as MeshInstance3D
		if child_node:
			var current_material: Material = child_node.material_override
			if current_material == null:
				current_material = child_node.get_active_material(0)
			
			# Duplicate material so changes are instance-specific.
			var new_material = current_material.duplicate() if current_material else StandardMaterial3D.new()
			new_material.emission_enabled = true
			# Choose emission color based on local PvP mode:
			# In local PvP, mimic blue castle behavior but swap the blue glow for a red glow.
			if GlobalVars.is_local_pvp or !GlobalVars.is_host:
				new_material.emission = Color(0.7, 0.1, 0.1)
			else:
				new_material.emission = Color(0.5, 0.1, 0.1)
			new_material.emission_energy = 2.0
			child_node.material_override = new_material
			
			# In local PvP mode, do additional steps like the blue castle:
			if GlobalVars.is_local_pvp or !GlobalVars.is_host:
				GlobalVars.castle_selected = true
				var board = get_parent()
				# If the game is in the MOVE_PHASE, update castle coordinates and highlight moves.
				if board.control_node.game_state == board.control_node.GameState.MOVE_PHASE:
					GlobalVars.castle_coords = coordsfromboard
					get_valid_move_locations()

func _process(delta: float) -> void:
	# Reset the material override when this piece is no longer selected.
	if GlobalVars.hex_selected != coordsfromboard:
		var child_node = self.get_child(0) as MeshInstance3D
		var original_material = load("res://Assets/obj/buildings/red/building_castle_red.obj")
		child_node.material_override = original_material

func update_piece_count(piece_count):
	var count_label = $TokenCount
	count_label.modulate = Color(1.0, .19, .15 ) 
	count_label.text = var_to_str(piece_count)

func get_valid_move_locations():
	# Similar to the blue castle script.
	var board = get_parent()
	var controller = board.get_node("GameControl")
	var moves = controller.get_valid()
	
	var unique_directions = []
	for move in moves:
		var dir_index = move["directionIndex"]
		if dir_index not in unique_directions:
			unique_directions.append(dir_index)
	
	var valid_tiles = []
	for direction in unique_directions:
		var tile = controller.game_engine.GetFurthestUnoccupiedHexCoords(coordsfromboard.x, coordsfromboard.y, direction)
		valid_tiles.append(tile)
		
	GlobalVars.valid_move_tiles = valid_tiles
