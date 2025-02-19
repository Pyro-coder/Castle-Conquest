extends Node3D
const TILE_SIZE := 1.0
const HEX_TILE = preload("res://Scenes/water_hex.tscn")
const FOREST_TILE = preload("res://Scenes/forest_hex.tscn")
@export_range(2, 20) var grid_size: int = 20





var tile_map = {}

func _ready() -> void:
	_generate_grid()
	
	#change_tile(Vector2i(_offset(0),_offset(0)))
	var board = _return_test_board()
	for i in range(board.size()):
		var hex = board[i]
		var xcoord = hex.x
		var ycoord = hex.y
		change_tile(Vector2i(_offset(ycoord),_offset(xcoord)))
	

func _return_test_board():
	var board1 = [
		Vector4(0, 0, 16, 1),
		Vector4(2, -1, 16, 2),
		Vector4(1, -1, 0, -1),
		Vector4(1, 0, 0, -1),
		Vector4(0, 1, 0, -1),
		Vector4(-1, 1, 0, -1),
		Vector4(-1, 0, 0, -1),
		Vector4(0, -1, 0, -1)
	]
	var board2 = [
	Vector4(0,  0, 10, 1),  # Player 1 left 10 pieces at the initial cell.
	Vector4(0, -1,  6, 1),  # Player 1 moved 6 pieces to an adjacent cell.
	Vector4(2, -1, 10, 2),  # Player 2 left 10 pieces at the initial cell.
	Vector4(1, -1,  6, 2),  # Player 2 moved 6 pieces to an adjacent cell.
	Vector4(1,  0,  0, -1),
	Vector4(0,  1,  0, -1),
	Vector4(-1, 1,  0, -1),
	Vector4(-1, 0,  0, -1)
]
	return board2

func _offset(coordinate):
	
	return coordinate + grid_size/2


func _generate_grid():
	var y_offset = 0.0  # Start offset at 0
	
	# First, generate the grid as usual
	for x in range(grid_size):
		for y in range(grid_size):
			var tile = HEX_TILE.instantiate()
			var coords = Vector2i(x, y)
			add_child(tile)
			
			
			var world_position = _axial_to_world(Vector2(coords))
			tile.translate(Vector3(world_position.x, 0, world_position.y))
			tile_map[coords] = tile
			tile.set_meta("hex_coords", coords)
		
		y_offset += 0.5  # Smooth offset per row
	
	# Now, apply the offset to center the grid by translating all tiles in the tile_map
	var grid_offset = Vector3(-TILE_SIZE * grid_size / 2.0, 0, -TILE_SIZE * grid_size / 2.0)
	for tile in tile_map.values():
		tile.translate(grid_offset)

		
func _axial_to_world(coords: Vector2) -> Vector2:
	var x = coords.x * TILE_SIZE * 2.0 * cos(deg_to_rad(30))
	var y = coords.y * TILE_SIZE * 2.0 + (TILE_SIZE if int(coords.x) % 2 != 0 else 0)
	return Vector2(x, y)
	
func get_tile_at(coords: Vector2):
	return tile_map.get(coords, null)
	
	
func change_tile(coords: Vector2i) -> void:
	if tile_map.has(coords):
		var old_tile = tile_map[coords]
		var new_tile = FOREST_TILE.instantiate()
		
		# Preserve position and transformation
		new_tile.transform = old_tile.transform
		new_tile.rotate(Vector3.UP, deg_to_rad(90))
		new_tile.scale *= 2
		new_tile.set_meta("hex_coords", coords)

		# Replace in the tile map
		remove_child(old_tile)
		old_tile.queue_free()
		
		add_child(new_tile)
		tile_map[coords] = new_tile
	
