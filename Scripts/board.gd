extends Node3D

const TILE_SIZE := 1.0
const HEX_TILE = preload("res://Scenes/water_hex.tscn")
const FOREST_TILE = preload("res://Scenes/forest_hex.tscn")
const BLUE_CASTLE = preload("res://Scenes/castle_hex_blue.tscn")
const RED_CASTLE = preload("res://Scenes/castle_hex_red.tscn")
var orientation = "vert"
@export_range(2, 50) var grid_size: int = 50
@export var spacing_factor: float = 1.15  # Increase this value if tiles overlap

var tile_map = {}

var hoveredTile = Vector2i(0,0)
var tempColor

var example_board_state = [
	[0, 0, 1, 1],  # A blue piece at (0, 0) (player_id 1)
	[1, 0, 1, 2],  # A red piece at (1, 0) (player_id 2)
	[0, 1, 0, -1]  # An empty cell at (0, 1) (piece_count 0, player_id -1)
]

func _ready() -> void:
	_generate_grid()      
	# update_from_state(example_board_state)
	

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("spacebar push")
		OnBoardPlaceHover(hoveredTile,Color(0.12, 0.28, 0.66, 1.0))
		if(orientation == "vert"):
			orientation = "left"
			
		elif(orientation == "left"):
			orientation = "right"
			
		elif(orientation == "right"):
			orientation = "vert"
		
		OnBoardPlaceHover(hoveredTile,Color(0.8, 0.1, 0.1, 1.0))
			


func OnBoardPlaceHover(hoveredtilecoords,color):
	hoveredTile = hoveredtilecoords
	tempColor = color
	if orientation == "vert":
		vertNeighborCoords(hoveredtilecoords,color)
	if orientation == "right":
		rightNeighborCoords(hoveredtilecoords,color)
	if orientation == "left":
		leftNeighborCoords(hoveredtilecoords,color)
	


func OnBoardPlaceClick(hoveredtilecoords):
	hoveredTile = hoveredtilecoords
	if orientation == "vert":
		changeVneighbor(hoveredtilecoords)
	if orientation == "right":
		changeRneighbor(hoveredtilecoords)
	if orientation == "left":
		changeLneighbor(hoveredtilecoords)
	

func isNotForest(neighbor):
	if neighbor.get_child(0).has_method("type"):
		return true
	else:
		return false

#WORKS
func vertNeighborCoords(hoveredtilecoords,color):
	var tile = get_tile_at(hoveredtilecoords)
	var neighbor1 = get_tile_at(Vector2i(hoveredtilecoords.x-1,hoveredtilecoords.y+1))
	var neighbor2 = get_tile_at(Vector2i(hoveredtilecoords.x,hoveredtilecoords.y+1))
	var neighbor3 = get_tile_at(Vector2i(hoveredtilecoords.x -1,hoveredtilecoords.y+2))
	
	if isNotForest(neighbor1) and isNotForest(neighbor2) and isNotForest(neighbor3) and isNotForest(tile):
		neighbor1.get_child(0)._change_color(color)
		neighbor2.get_child(0)._change_color(color)
		neighbor3.get_child(0)._change_color(color)
		tile.get_child(0)._change_color(color)
#WORKS
func changeVneighbor(hoveredtilecoords):
	var tile = get_tile_at(hoveredtilecoords)
	var neighbor1 = get_tile_at(Vector2i(hoveredtilecoords.x-1,hoveredtilecoords.y+1))
	var neighbor2 = get_tile_at(Vector2i(hoveredtilecoords.x,hoveredtilecoords.y+1))
	var neighbor3 = get_tile_at(Vector2i(hoveredtilecoords.x -1,hoveredtilecoords.y+2))
	
	if isNotForest(neighbor1) and isNotForest(neighbor2) and isNotForest(neighbor3) and isNotForest(tile):
		neighbor1.get_child(0)._replace_tile()
		neighbor2.get_child(0)._replace_tile()
		neighbor3.get_child(0)._replace_tile()
		tile.get_child(0)._replace_tile()




func rightNeighborCoords(hoveredtilecoords,color):
	var tile = get_tile_at(hoveredtilecoords)
	var neighbor1 = get_tile_at(Vector2i(hoveredtilecoords.x+1,hoveredtilecoords.y))
	var neighbor2 = get_tile_at(Vector2i(hoveredtilecoords.x+1,hoveredtilecoords.y-1))
	var neighbor3 = get_tile_at(Vector2i(hoveredtilecoords.x + 2,hoveredtilecoords.y - 1))
	
	if isNotForest(neighbor1) and isNotForest(neighbor2) and isNotForest(neighbor3) and isNotForest(tile):
		neighbor1.get_child(0)._change_color(color)
		neighbor2.get_child(0)._change_color(color)
		neighbor3.get_child(0)._change_color(color)
		tile.get_child(0)._change_color(color)

func changeRneighbor(hoveredtilecoords):
	var tile = get_tile_at(hoveredtilecoords)
	var neighbor1 = get_tile_at(Vector2i(hoveredtilecoords.x+1,hoveredtilecoords.y))
	var neighbor2 = get_tile_at(Vector2i(hoveredtilecoords.x+1,hoveredtilecoords.y-1))
	var neighbor3 = get_tile_at(Vector2i(hoveredtilecoords.x + 2,hoveredtilecoords.y - 1))
	
	if isNotForest(neighbor1) and isNotForest(neighbor2) and isNotForest(neighbor3) and isNotForest(tile):
		neighbor1.get_child(0)._replace_tile()
		neighbor2.get_child(0)._replace_tile()
		neighbor3.get_child(0)._replace_tile()
		tile.get_child(0)._replace_tile()





func leftNeighborCoords(hoveredtilecoords,color):
	var tile = get_tile_at(hoveredtilecoords)
	var neighbor1 = get_tile_at(Vector2i(hoveredtilecoords.x-1,hoveredtilecoords.y-1))
	var neighbor2 = get_tile_at(Vector2i(hoveredtilecoords.x,hoveredtilecoords.y - 1))
	var neighbor3 = get_tile_at(Vector2i(hoveredtilecoords.x-1,hoveredtilecoords.y))
	
	if isNotForest(neighbor1) and isNotForest(neighbor2) and isNotForest(neighbor3) and isNotForest(tile):
		neighbor1.get_child(0)._change_color(color)
		neighbor2.get_child(0)._change_color(color)
		neighbor3.get_child(0)._change_color(color)
		tile.get_child(0)._change_color(color)
		
		
		
func changeLneighbor(hoveredtilecoords):
	var tile = get_tile_at(hoveredtilecoords)
	var neighbor1 = get_tile_at(Vector2i(hoveredtilecoords.x-1,hoveredtilecoords.y-1))
	var neighbor2 = get_tile_at(Vector2i(hoveredtilecoords.x,hoveredtilecoords.y - 1))
	var neighbor3 = get_tile_at(Vector2i(hoveredtilecoords.x-1,hoveredtilecoords.y))
	
	if isNotForest(neighbor1) and isNotForest(neighbor2) and isNotForest(neighbor3) and isNotForest(tile):
		neighbor1.get_child(0)._replace_tile()
		neighbor2.get_child(0)._replace_tile()
		neighbor3.get_child(0)._replace_tile()
		tile.get_child(0)._replace_tile()




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
	

func update_from_state(board_state: Array) -> void:
	for cell in board_state:
		var q = cell["q"]
		var r = cell["r"]
		var piece_count = cell["pieceCount"]
		var player_id = cell["playerId"]
		var tile_type = ""
		if piece_count > 0:
			if player_id == 1:
				tile_type = "blue"
			elif player_id == 2:
				tile_type = "red"
			else:
				tile_type = "forest"
		else:
			tile_type = "forest"
		change_tile(Vector2i(q, r), tile_type)


func change_tile(coords: Vector2i, type: String) -> void:
	if tile_map.has(coords):
		var old_tile = tile_map[coords]
		# Check if the tile was already modified.
		var already_modified = old_tile.has_meta("modified") and old_tile.get_meta("modified")
		
		var new_tile
		match type:
			"blue":
				new_tile = BLUE_CASTLE.instantiate()
			"red":
				new_tile = RED_CASTLE.instantiate()
			"forest":
				new_tile = FOREST_TILE.instantiate()
			"default":
				new_tile = HEX_TILE.instantiate()
			_:
				return
		
		# Copy the transform from the old tile.
		new_tile.transform = old_tile.transform
		# Apply rotation and scaling only if this tile hasn't been modified before.
		if not already_modified:
			new_tile.rotate(Vector3.UP, deg_to_rad(90))
			new_tile.scale *= 2
		# Ensure that the new tile always carries the "modified" flag.
		new_tile.set_meta("modified", true)
		new_tile.set_meta("hex_coords", coords)
		
		remove_child(old_tile)
		old_tile.queue_free()
		add_child(new_tile)
		tile_map[coords] = new_tile
