extends MeshInstance3D
@export var blue_castle: PackedScene = preload("res://Scenes/castle_hex_blue.tscn")
var material := StandardMaterial3D.new()
var tileType = "forest"
var coordsfromboard

var valid_index: int

@onready var board = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.albedo_color = Color(0.3, 0.6, 0.3, 1.0)
	set_surface_override_material(0, material)



func type():
	return tileType
	
func setcoords(vector):
	coordsfromboard = vector
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Change the color if pieces can be moved here 
	if is_valid_tile():
		_change_color("green")
	elif board.control_node.game_state == board.control_node.GameState.MOVE_PHASE:
		_change_color(Color(0.3, 0.6, 0.3, 1))

	
func _change_color(color: Color):
	material.albedo_color = color
	set_surface_override_material(0, material)

func placetoken(numTokens):
	if numTokens == 16:
		change_to_token_hex(blue_castle)
		

func change_to_token_hex(building_type):
		var new_tile = building_type.instantiate()
		new_tile.transform = self.transform  # Keep the same position.
		#new_tile.get_child(0).setcoords(coordsfromboard)
		get_parent().get_parent().add_child(new_tile)
		queue_free()  # Remove the old tile.
	
func _on_area_3d_mouse_entered() -> void:
	# Only allow placing tiles in the tile placement phase, and when it is the current user's turn
	if (board.control_node.game_state == board.control_node.GameState.TILE_PLACEMENT && GlobalVars.player_turn):
		
		# Use the tile’s meta to get its coordinate.
		board.OnBoardPlaceHover(coordsfromboard, Color(0.8, 0.1, 0.1, 1.0))
	elif board.control_node.game_state == board.control_node.GameState.INITIAL_PLACEMENT and GlobalVars.player_turn:
		var valid_moves = board.control_node.get_valid()
		var is_valid = false
		
		for move in valid_moves:
			if move["q"] == coordsfromboard.x and move["r"] == coordsfromboard.y:
				is_valid = true
				break
		if is_valid:	
			_change_color("green") #Color(0.5, 0.8, 0.5, 1)
		else:
			_change_color("red")

func _on_area_3d_mouse_exited() -> void:
	# Only allow placing tiles in the tile placement phase, and when it is the current user's turn
	if (board.control_node.game_state == board.control_node.GameState.TILE_PLACEMENT && GlobalVars.player_turn):
		board.OnBoardPlaceHoverExit(coordsfromboard, Color(0.12, 0.28, 0.66, 1.0))
	elif board.control_node.game_state == board.control_node.GameState.INITIAL_PLACEMENT:
		_change_color(Color(0.3, 0.6, 0.3, 1))



	

func _on_area_3d_input_event(camera, event, position, normal, shape_idx) -> void:
	if Input.is_action_pressed("ui_click"):		
		if is_valid_tile() and board.control_node.game_state == board.control_node.GameState.MOVE_PHASE and GlobalVars.player_turn:
			# If this is a valid tile in the piece movement phase, and everything is set, move tiles
			board.control_node.process_move_input(GlobalVars.castle_coords.x, GlobalVars.castle_coords.y, GlobalVars.num_pieces_selected, valid_index)
		
		GlobalVars.hex_selected = coordsfromboard
		GlobalVars.castle_selected = false
		GlobalVars.valid_move_tiles = []
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and board.control_node.game_state == board.control_node.GameState.INITIAL_PLACEMENT and GlobalVars.player_turn:
		board.control_node.process_initial_input(coordsfromboard.x, coordsfromboard.y)
		
	

func is_valid_tile() -> bool:
	for tile in GlobalVars.valid_move_tiles:
		print(tile)
		if tile["q"] == coordsfromboard.x and tile["r"] == coordsfromboard.y:
			valid_index = tile["i"]
			return true
	return false
