extends MeshInstance3D

var unique_material: StandardMaterial3D
@export var new_tile_scene: PackedScene = preload("res://Scenes/forest_hex.tscn")

func _ready() -> void:
	unique_material = get_surface_override_material(0).duplicate()
	set_surface_override_material(0, unique_material)

func _on_area_3d_mouse_entered() -> void:
	# var coords = get_meta("hex_coords")
	# print ("Hovered tile coordinates: ", coords)
	_change_color(Color(1, .2, .3, 1))  # Make red
	_apply_to_neighbors("_change_color", Color(1, .2, .3, 1))  # Also apply to neighbors

func _on_area_3d_mouse_exited() -> void:
	_change_color(Color(.4, .8, .9, 1))  # Make blue
	_apply_to_neighbors("_change_color", Color(.4, .8, .9, 1))  # Also apply to neighbors

func _on_area_3d_input_event(camera, event, position, normal, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_replace_tile()
		_apply_to_neighbors("_replace_tile")  # Also replace neighbors

func _change_color(color: Color):
	unique_material.albedo_color = color

func _replace_tile() -> void:
	if new_tile_scene:
		var new_tile = new_tile_scene.instantiate()
		new_tile.transform = self.transform  # Keep the same position
		get_parent().add_child(new_tile)
		queue_free()  # Remove the old tile

# Apply an action (like color change or tile replacement) to neighbors
func _apply_to_neighbors(action: String, param = null):
	var parent_board = get_parent()
	if parent_board and parent_board.has_method("get_tile_at"):
		var coords = get_meta("hex_coords") as Vector2i

		# Axial hex coordinate offsets for right, left, and front neighbors
		var neighbor_offsets = [
			Vector2(1, 0),  # Right
			Vector2(-1, 0),  # Left
			Vector2(0, 1)  # Front
		]

		for offset in neighbor_offsets:
			var neighbor_coords = coords + offset
			var neighbor_tile = parent_board.get_tile_at(neighbor_coords)
			if neighbor_tile:
				print ("Neighbor found at:", neighbor_coords)
				if neighbor_tile.has_method(action):
					if param != null:
						neighbor_tile.call(action, param)
					else:
						neighbor_tile.call(action)
