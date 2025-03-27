extends Node3D

const TILE_SIZE := 1.0
const HEX_TILE = preload("res://Scenes/fake_water_hex.tscn")

@export_range(2, 50) var grid_size: int = 50
@export var spacing_factor: float = 1.15  # Increase this value if tiles overlap

#################### IMPORTANT ###################
# If control_node.turn_order[control_node.tile_turn_index].Id == 1, then it is the user's turn

var tile_map = {}

var hoveredTile = Vector2i(0,0)
var tempColor


func _ready() -> void:
	if GlobalVars.difficulty == 1:
		AudioPlayer.play_easy_music()
	if GlobalVars.difficulty == 2:
		AudioPlayer.play_medium_music()
	if GlobalVars.difficulty == 3:
		AudioPlayer.play_hard_music()
	
	_generate_grid()
  
	# update_from_state(example_board_state)
	


func _generate_grid() -> void:
	# Generate a hexagon-shaped board in axial coordinates.
	for q in range(-grid_size, grid_size + 1):
		var r_min = max(-grid_size, -q - grid_size)
		var r_max = min(grid_size, -q + grid_size)
		for r in range(r_min, r_max + 1):
			var tile = HEX_TILE.instantiate()
			tile.rotation_degrees = Vector3.ZERO  # Reset rotation.
			var coords = Vector2i(q, r)
			
			var world_pos: Vector2 = _axial_to_world(Vector2(q, r))
			tile.position = Vector3(world_pos.x, 0, world_pos.y)
			tile_map[coords] = tile
			tile.set_meta("hex_coords", coords)
			tile.get_child(0).setcoords(coords)
			tile.get_child(0).board = self
			

			add_child(tile)
	# Optionally, center the grid by applying an offset.
	var grid_offset = Vector3(-TILE_SIZE * grid_size, 0, -TILE_SIZE * grid_size)
	for tile in tile_map.values():
		tile.position += grid_offset

func _axial_to_world(coords: Vector2) -> Vector2:
	# Original formula for flat-topped hexes using axial coordinates:
	# x = TILE_SIZE * 1.5 * q
	# y = TILE_SIZE * sqrt(3) * (r + 0.5 * q)
	var x = TILE_SIZE * 1.5 * coords.x * spacing_factor
	var y = TILE_SIZE * sqrt(3) * (coords.y + 0.5 * coords.x) * spacing_factor
	return Vector2(x, y)

func get_tile_at(coords: Vector2i) -> Node:
	return tile_map.get(coords, null)
	
