extends Node3D

const TILE_SIZE := 1.0
const WATER_TILE = preload("res://Scenes/water_hex.tscn")
const FOREST_TILE = preload("res://Scenes/forest_hex.tscn")
const BLUE_CASTLE = preload("res://Scenes/castle_hex_blue.tscn")
const BLUE_BARRACKS = preload("res://Scenes/barracks_hex_blue.tscn")
const BLUE_TOWER = preload("res://Scenes/tower_hex_blue.tscn")
const BLUE_CHURCH = preload("res://Scenes/church_hex_blue.tscn")
const BLUE_MARKET = preload("res://Scenes/market_hex_blue.tscn")
const BLUE_TAVERN = preload("res://Scenes/tavern_hex_blue.tscn")
const BLUE_BLACKSMITH = preload("res://Scenes/blacksmith_hex_blue.tscn")
const BLUE_LARGEHOUSE = preload("res://Scenes/largehouse_hex_blue.tscn")
const BLUE_SMALLHOUSE = preload("res://Scenes/smallhouse_hex_blue.tscn")



const RED_CASTLE = preload("res://Scenes/castle_hex_red.tscn")
const RED_BARRACKS = preload("res://Scenes/barracks_hex_red.tscn")
const RED_TOWER = preload("res://Scenes/tower_hex_red.tscn")
const RED_CHURCH = preload("res://Scenes/church_hex_red.tscn")
const RED_MARKET = preload("res://Scenes/market_hex_red.tscn")
const RED_TAVERN = preload("res://Scenes/tavern_hex_red.tscn")
const RED_BLACKSMITH = preload("res://Scenes/blacksmith_hex_red.tscn")
const RED_LARGEHOUSE = preload("res://Scenes/largehouse_hex_red.tscn")
const RED_SMALLHOUSE = preload("res://Scenes/smallhouse_hex_red.tscn")


var orientation = "vert"
@export_range(2, 50) var grid_size: int = 50
@export var spacing_factor: float = 1.15  # Increase this value if tiles overlap

#################### IMPORTANT ###################
# If control_node.turn_order[control_node.tile_turn_index].Id == 1, then it is the user's turn

var tile_map = {}

var hoveredTile = Vector2i(0,0)
var tempColor

var isPauseHovered = false

@onready var control_node = get_node("GameControl")


func _ready() -> void:
	_generate_grid()
	


	# update_from_state(example_board_state)
	

func _input(event):
	if event.is_action_pressed("rotate_tile") and control_node.game_state == control_node.GameState.TILE_PLACEMENT and GlobalVars.player_turn or event.is_action_pressed("rotate_tile") and control_node.game_state == control_node.GameState.TILE_PLACEMENT and GlobalVars.is_local_pvp:
		print("spacebar push")
		OnBoardPlaceHoverExit(hoveredTile,Color(0.12, 0.28, 0.66, 1.0))
		if(orientation == "vert"):
			orientation = "left"
			
		elif(orientation == "left"):
			orientation = "right"
			
		elif(orientation == "right"):
			orientation = "vert"
		
		OnBoardPlaceHover(hoveredTile,Color(0.8, 0.1, 0.1, 1.0))
			

func updatePauseHovered(isHovered):
	if isHovered:
		isPauseHovered = true
	else:
		isPauseHovered = false
func OnBoardPlaceHover(hoveredtilecoords,color):
	# Get valid moves for tile coloring
	var valid_moves = control_node.get_valid()
	var is_valid = false
	hoveredTile = hoveredtilecoords
	if orientation == "vert":
		for move in valid_moves:
			if move["q"] == hoveredtilecoords.x and move["r"] == hoveredtilecoords.y and move["orientation"] == 1:
				is_valid = true
				break
		if is_valid:
			tempColor = Color(0, 1, 0, 1)
			vertNeighborCoords(hoveredtilecoords,tempColor)
		elif control_node.tile_turn_index == 0 and control_node.tile_round == 1:
			tempColor = Color(0, 1, 0, 1)
			vertNeighborCoords(hoveredtilecoords,tempColor)
		else:
			tempColor = color
			vertNeighborCoords(hoveredtilecoords,tempColor)
	
	
	if orientation == "right":
		for move in valid_moves:
			if move["q"] == hoveredtilecoords.x and move["r"] == hoveredtilecoords.y and move["orientation"] == 0:
				is_valid = true
				break
		if is_valid:
			tempColor = Color(0, 1, 0, 1)
			rightNeighborCoords(hoveredtilecoords,tempColor)
		elif control_node.tile_turn_index == 0 and control_node.tile_round == 1:
			tempColor = Color(0, 1, 0, 1)
			rightNeighborCoords(hoveredtilecoords,tempColor)
		else:
			tempColor = color
			rightNeighborCoords(hoveredtilecoords,tempColor)
			
			
	if orientation == "left":
		for move in valid_moves:
			if move["q"] == hoveredtilecoords.x and move["r"] == hoveredtilecoords.y and move["orientation"] == 2:
				is_valid = true
				break
		if is_valid:
			tempColor = Color(0, 1, 0, 1)
			leftNeighborCoords(hoveredtilecoords,tempColor)
		elif control_node.tile_turn_index == 0 and control_node.tile_round == 1:
			tempColor = Color(0, 1, 0, 1)
			leftNeighborCoords(hoveredtilecoords,tempColor)
		else:
			tempColor = color
			leftNeighborCoords(hoveredtilecoords,tempColor)
	
	
func OnBoardPlaceHoverExit(hoveredtilecoords,color):
	if orientation == "vert":
		tempColor = color
		vertNeighborCoords(hoveredtilecoords,tempColor)
	
	if orientation == "right":
		tempColor = color
		rightNeighborCoords(hoveredtilecoords,tempColor)
			
			
	if orientation == "left":
		tempColor = color
		leftNeighborCoords(hoveredtilecoords,tempColor)


func OnBoardPlaceClick(hoveredtilecoords):
	
	hoveredTile = hoveredtilecoords
	if (control_node.tile_turn_index == 0 and control_node.tile_round == 1):
		hoveredTile.x = 0
		hoveredTile.y = 0
	if not isPauseHovered:	
		if orientation == "vert":
			control_node.process_tile_input(hoveredTile.x, hoveredTile.y, 1)
		if orientation == "right":
			control_node.process_tile_input(hoveredTile.x, hoveredTile.y, 0)
		if orientation == "left":
			control_node.process_tile_input(hoveredTile.x, hoveredTile.y, 2)
		

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
	
	if neighbor1.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		neighbor1.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		neighbor1.get_child(0)._change_color(color)
	
	if neighbor2.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		neighbor2.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		neighbor2.get_child(0)._change_color(color)
	
	if neighbor3.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		neighbor3.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		neighbor3.get_child(0)._change_color(color)
		
	if tile.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		tile.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		tile.get_child(0)._change_color(color)




func rightNeighborCoords(hoveredtilecoords,color):
	var tile = get_tile_at(hoveredtilecoords)
	var neighbor1 = get_tile_at(Vector2i(hoveredtilecoords.x+1,hoveredtilecoords.y))
	var neighbor2 = get_tile_at(Vector2i(hoveredtilecoords.x+1,hoveredtilecoords.y-1))
	var neighbor3 = get_tile_at(Vector2i(hoveredtilecoords.x + 2,hoveredtilecoords.y - 1))
	
	if neighbor1.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		neighbor1.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		neighbor1.get_child(0)._change_color(color)
	
	if neighbor2.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		neighbor2.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		neighbor2.get_child(0)._change_color(color)
	
	if neighbor3.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		neighbor3.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		neighbor3.get_child(0)._change_color(color)
		
	if tile.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		tile.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		tile.get_child(0)._change_color(color)






func leftNeighborCoords(hoveredtilecoords,color):
	var tile = get_tile_at(hoveredtilecoords)
	var neighbor1 = get_tile_at(Vector2i(hoveredtilecoords.x-1,hoveredtilecoords.y-1))
	var neighbor2 = get_tile_at(Vector2i(hoveredtilecoords.x,hoveredtilecoords.y - 1))
	var neighbor3 = get_tile_at(Vector2i(hoveredtilecoords.x-1,hoveredtilecoords.y))
	
	if neighbor1.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		neighbor1.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		neighbor1.get_child(0)._change_color(color)
	
	if neighbor2.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		neighbor2.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		neighbor2.get_child(0)._change_color(color)
	
	if neighbor3.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		neighbor3.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		neighbor3.get_child(0)._change_color(color)
		
	if tile.get_child(0).tileType == "forest" and color == Color(0.12, 0.28, 0.66, 1.0):
		tile.get_child(0)._change_color(Color(0.3, 0.6, 0.3, 1.0))
	else:
		tile.get_child(0)._change_color(color)




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
			var tile = WATER_TILE.instantiate()
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
	

func update_from_state(board_state: Array) -> void:
	for cell in board_state:
		var q = cell["q"]
		var r = cell["r"]
		var piece_count = cell["pieceCount"]
		var player_id = cell["playerId"]
		var tile_type = ""
		if piece_count > 0:
			if player_id == 1:
				if piece_count == 16:
					tile_type = "blue-castle"
				if piece_count == 15 || piece_count == 14:
					tile_type = "blue-barracks"
				if piece_count == 13 || piece_count == 12:
					tile_type = "blue-tower"
				if piece_count == 11 || piece_count == 10:
					tile_type = "blue-church"
				if piece_count == 9 || piece_count == 8:
					tile_type = "blue-market"		
				if piece_count == 7 || piece_count == 6:
					tile_type = "blue-tavern"
				if piece_count == 5 || piece_count == 4:
					tile_type = "blue-blacksmith"
				if piece_count == 3 || piece_count == 2:
					tile_type = "blue-largehouse"
				if piece_count == 1:
					tile_type = "blue-smallhouse"
					
			elif player_id == 2:
				if piece_count == 16:
					tile_type = "red-castle"
				if  piece_count == 15 || piece_count == 14:
					tile_type = "red-barracks"
				if  piece_count == 13 || piece_count == 12:
					tile_type = "red-tower"
				if  piece_count == 11 || piece_count == 10:
					tile_type = "red-church"
				if  piece_count == 9 || piece_count == 8:
					tile_type = "red-market"
				if  piece_count == 7 || piece_count == 6:
					tile_type = "red-tavern"
				if  piece_count == 5 || piece_count == 4:
					tile_type = "red-blacksmith"
				if  piece_count == 3 || piece_count == 2:
					tile_type = "red-largehouse"
				if  piece_count == 1:
					tile_type = "red-smallhouse"
			else:
				tile_type = "forest"
		else:
			tile_type = "forest"
		change_tile(Vector2i(q, r), tile_type,piece_count)


func change_tile(coords: Vector2i, type: String,piece_count) -> void:
	if tile_map.has(coords):
		var old_tile = tile_map[coords]
		# Check if the tile was already modified.
		var already_modified = old_tile.has_meta("modified") and old_tile.get_meta("modified")
		
		var new_tile
		match type:
			"blue-castle":
				new_tile = BLUE_CASTLE.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
			"blue-barracks":
				new_tile = BLUE_BARRACKS.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
				
			"blue-tower":
				new_tile = BLUE_TOWER.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
				
			"blue-church":
				new_tile = BLUE_CHURCH.instantiate()
				new_tile.setcoords(coords)	
				new_tile.update_piece_count(piece_count)
				
			"blue-market":
				new_tile = BLUE_MARKET.instantiate()
				new_tile.setcoords(coords)	
				new_tile.update_piece_count(piece_count)
				
			"blue-tavern":
				new_tile = BLUE_TAVERN.instantiate()
				new_tile.setcoords(coords)	
				new_tile.update_piece_count(piece_count)
				
			"blue-blacksmith":
				new_tile = BLUE_BLACKSMITH.instantiate()
				new_tile.setcoords(coords)	
				new_tile.update_piece_count(piece_count)
				
			"blue-largehouse":
				new_tile = BLUE_LARGEHOUSE.instantiate()
				new_tile.setcoords(coords)	
				new_tile.update_piece_count(piece_count)
				
			"blue-smallhouse":
				new_tile = BLUE_SMALLHOUSE.instantiate()
				new_tile.setcoords(coords)	
				new_tile.update_piece_count(piece_count)
				
				
			
				
			"red-castle":
				new_tile = RED_CASTLE.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
				
			"red-barracks":
				new_tile = RED_BARRACKS.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
				
			"red-tower":
				new_tile = RED_TOWER.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
				
			"red-church":
				new_tile = RED_CHURCH.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
				
			"red-market":
				new_tile = RED_MARKET.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
				
			"red-tavern":
				new_tile = RED_TAVERN.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
				
			"red-blacksmith":
				new_tile = RED_BLACKSMITH.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
				
			"red-largehouse":
				new_tile = RED_LARGEHOUSE.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
				
			"red-smallhouse":
				new_tile = RED_SMALLHOUSE.instantiate()
				new_tile.setcoords(coords)
				new_tile.update_piece_count(piece_count)
				
				
				
				
				
			"forest":
				new_tile = FOREST_TILE.instantiate()
				new_tile.get_child(0).setcoords(coords)
			"default":
				new_tile = WATER_TILE.instantiate()
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
