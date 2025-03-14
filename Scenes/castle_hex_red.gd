extends Node3D



var coordsfromboard

func setcoords(vector):
	coordsfromboard = vector

func _ready() -> void:
	add_to_group("Pieces")

func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if Input.is_action_pressed("ui_click"):
		print("castle clicked")
		
		# Get the first child and cast it to MeshInstance3D
		var child_node = self.get_child(0) as MeshInstance3D
		if child_node:
			var current_material: Material = child_node.material_override
			# If no material override is set, try getting the material from the first surface.
			if current_material == null:
				current_material = child_node.get_active_material(0)
			
			# Duplicate the material so that changes affect only this instance.
			var new_material = current_material.duplicate() if current_material else StandardMaterial3D.new()
			
			# If using StandardMaterial3D, change the albedo (base) color.
			new_material.albedo_color = Color(1, 0, 0)  # Change to red as an example.
			
			# Apply the modified material as an override.
			child_node.material_override = new_material



func _on_static_body_3d_mouse_exited() -> void:
	var child_node = self.get_child(0) as MeshInstance3D
	var original_material = load("res://Assets/obj/buildings/red/building_castle_red.obj::StandardMaterial3D_2ks4u")
	child_node.material_override = original_material
