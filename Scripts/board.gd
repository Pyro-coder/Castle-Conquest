extends Node3D

const TILE_SIZE := 1.0
const HEX_TILE = preload("res://Scenes/water_hex.tscn")
const FOREST_TILE = preload("res://Scenes/forest_hex.tscn")
const BLUE_CASTLE = preload("res://Scenes/castle_hex_blue.tscn")
const RED_CASTLE = preload("res://Scenes/castle_hex_red.tscn")


@export_range(2, 44) var grid_size: int = 30
@export var spacing_factor: float = 1.15  # Increase this value if tiles overlap

var tile_map = {}


func _ready() -> void:
	_generate_grid()
	
	var tile = get_tile_at(Vector2i(8,8))
	print(tile.get_child(0)._change_color(Color.RED))
	# For testing, change some tiles using original change_tile logic:
	change_tile(Vector2i(0, 0), "forest")
	change_tile(Vector2i(0, 1), "blue")
	change_tile(Vector2i(0, 2), "blue")
	change_tile(Vector2i(0, 3), "blue")
	change_tile(Vector2i(0, 4), "blue")
	change_tile(Vector2i(1, 0), "red")
	change_tile(Vector2i(2, 0), "red")
	change_tile(Vector2i(3, 0), "red")
	change_tile(Vector2i(4, 0), "red")
	
	



func vertNeighborCoords(hoveredtilecoords,color):
	var tile = get_tile_at(hoveredtilecoords)
	var neighbor = get_tile_at(Vector2i(hoveredtilecoords.x+1,hoveredtilecoords.y))
	if neighbor.get_child(0).type() == "water":
		neighbor.get_child(0)._change_color(color)

func changeVneighbor(hoveredtilecoords):
	var tile = get_tile_at(hoveredtilecoords)
	var neighbor = get_tile_at(Vector2i(hoveredtilecoords.x+1,hoveredtilecoords.y))
	neighbor.get_child(0)._replace_tile()

func rightNeighborCoords():
	pass

func lefttNeighborCoords():
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var camera = get_viewport().get_camera_3d()
		if camera == null:
			return
		var mouse_pos = event.position
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
		var query = PhysicsRayQueryParameters3D.new()
		query.from = from
		query.to = to
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(query)
		if result:
			var collider = result.collider
			if collider and collider.has_meta("hex_coords"):
				var hex_coords = collider.get_meta("hex_coords")
				print("Hovered hex: ", hex_coords)

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

func change_tile(coords: Vector2i, type: String) -> void:
	if tile_map.has(coords):
		var old_tile = tile_map[coords]
		var new_tile
		match type:
			"blue":
				new_tile = BLUE_CASTLE.instantiate()
			"red":
				new_tile = RED_CASTLE.instantiate()
			"forest":
				new_tile = FOREST_TILE.instantiate()
			_:
				return
		# Apply original transformation logic:
		new_tile.transform = old_tile.transform
		new_tile.rotate(Vector3.UP, deg_to_rad(90))
		new_tile.scale *= 2
		new_tile.set_meta("hex_coords", coords)
		remove_child(old_tile)
		old_tile.queue_free()
		add_child(new_tile)
		tile_map[coords] = new_tile
