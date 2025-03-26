extends Node3D



var coordsfromboard: Vector2i

func setcoords(vector):
	coordsfromboard = vector

func _ready() -> void:
	add_to_group("Pieces")

# func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	var board = get_parent()
	if Input.is_action_pressed("ui_click") and !GlobalVars.player_turn:
		print("castle clicked")
		GlobalVars.hex_selected = coordsfromboard
		# Get the first child and cast it to MeshInstance3D
		var child_node = self.get_child(0) as MeshInstance3D
		if child_node:
			var current_material: Material = child_node.material_override
			# If no material override is set, try getting the material from the first surface.
			if current_material == null:
				current_material = child_node.get_active_material(0)
			
			# Duplicate the material so that changes affect only this instance.
			var new_material = current_material.duplicate() if current_material else StandardMaterial3D.new()
	
			# Enable emission and set an emissive color.
			new_material.emission_enabled = true
			new_material.emission = Color(0.5, 0.1, 0.1)  # Same green color for glow.
			new_material.emission_energy = 2.0  # Increase brightness.

			# Apply the modified material as an override.
			child_node.material_override = new_material

func update_piece_count(piece_count):
	var count_label = $TokenCount
	count_label.text = var_to_str(piece_count)

# func _process(delta: float) -> void:
	if GlobalVars.hex_selected != coordsfromboard:
		var child_node = self.get_child(0) as MeshInstance3D
		var original_material = load("res://Assets/obj/buildings/red/building_castle_red.obj")
		child_node.material_override = original_material
