extends Node3D

const TILE_SIZE := 30.0
const HEX_TILE = preload("res://Scenes/water_hex.tscn") # Water hex tile
@export_range(2, 50) var grid_size: int = 20
@export var spacing_factor: float = 1.15  # Adjust spacing if needed

var tile_map = {}

func _ready() -> void:
	_generate_grid()

func _generate_grid() -> void:
	# Generate a square grid of hexagons using axial coordinates
	for q in range(-grid_size, grid_size + 1):
		var r_min = max(-grid_size, -q - grid_size)
		var r_max = min(grid_size, -q + grid_size)
		for r in range(r_min, r_max + 1):
			var tile = HEX_TILE.instantiate()
			tile.rotation_degrees = Vector3.ZERO  # Reset rotation
			var coords = Vector2i(q, r)
			
			var world_pos: Vector2 = _axial_to_world(Vector2(q, r))
			tile.position = Vector3(world_pos.x, 0, world_pos.y)
			tile_map[coords] = tile
			tile.set_meta("hex_coords", coords)

			add_child(tile)

	# Optionally, center the grid by applying an offset
	var grid_offset = Vector3(-TILE_SIZE * grid_size, 0, -TILE_SIZE * grid_size)
	for tile in tile_map.values():
		tile.position += grid_offset


func _axial_to_world(coords: Vector2) -> Vector2:
	# Convert axial coordinates to world position for hex placement
	var x = TILE_SIZE * 1.5 * coords.x * spacing_factor
	var y = TILE_SIZE * sqrt(3) * (coords.y + 0.5 * coords.x) * spacing_factor
	return Vector2(x, y)
