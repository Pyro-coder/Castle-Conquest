extends MeshInstance3D
@export var blue_castle: PackedScene = preload("res://Scenes/castle_hex_blue.tscn")
var material := StandardMaterial3D.new()
var tileType = "forest"
var board
var coordsfromboard
var numTokens=16
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.albedo_color = Color(0.3, 0.6, 0.3, 1.0)
	set_surface_override_material(0, material)
	board = get_parent().get_parent().get_parent()



func type():
	return tileType
	
func setcoords(vector):
	coordsfromboard = vector
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

	
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
	var board = get_parent().get_parent()  # board is now the direct parent of this tile.
	# Only allow placing tiles in the tile placement phase, and when it is the current user's turn
	if (board.control_node.game_state == board.control_node.GameState.TILE_PLACEMENT && board.control_node.turn_order[board.control_node.tile_turn_index].Id == 1):
		
		# Use the tile’s meta to get its coordinate.
		board.OnBoardPlaceHover(coordsfromboard, Color(0.8, 0.1, 0.1, 1.0))

func _on_area_3d_mouse_exited() -> void:
	var board = get_parent().get_parent()  # board is now the direct parent of this tile.
	# Only allow placing tiles in the tile placement phase, and when it is the current user's turn
	if (board.control_node.game_state == board.control_node.GameState.TILE_PLACEMENT && board.control_node.turn_order[board.control_node.tile_turn_index].Id == 1):
		board.OnBoardPlaceHoverExit(coordsfromboard, Color(0.12, 0.28, 0.66, 1.0))



	

#func _on_area_3d_input_event(camera, event, position, normal, shape_idx) -> void:
#	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
#		
#		tileType="forest"
#		board._forest_selected(coordsfromboard,numTokens)
