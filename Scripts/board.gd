extends Node3D
const TILE_SIZE := 1.0
const HEX_TILE = preload("res://Scenes/water_hex.tscn")
@export_range(2, 20) var grid_size: int = 20

var tile_map = {}

func _ready() -> void:
	_generate_grid()
	
func _generate_grid():
	for x in range(grid_size):
		for y in range(grid_size):
			var tile = HEX_TILE.instantiate()
			var coords = Vector2i(x, y)
			add_child(tile)
			
			var world_position = _axial_to_world(Vector2(coords))
			tile.translate(Vector3(world_position.x, 0, world_position.y))
			tile_map[coords] = tile
			tile.set_meta("hex_coords", coords)
			
			
func _axial_to_world(coords: Vector2) -> Vector2:
	var x = coords.x * TILE_SIZE * 2.0 * cos(deg_to_rad(30))
	var y = coords.y * TILE_SIZE * 2.0 + (TILE_SIZE if int(coords.x) % 2 != 0 else 0)
	return Vector2(x, y)
	
func get_tile_at(coords: Vector2):
	return tile_map.get(coords, null)
	
