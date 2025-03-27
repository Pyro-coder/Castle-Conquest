extends Control

# Define game states to control the flow.
enum GameState { TURN_ORDER, TILE_PLACEMENT, INITIAL_PLACEMENT, MOVE_PHASE, GAME_OVER }

# UI nodes.
@onready var message_label: Label = $MessageLabel

@onready var wait_timer = $Wait_Timer

@onready var board: Node = get_parent()  # Assumes the parent node contains an update_from_state(state) method.

# Game and AI objects.
var game_engine: GameEngine       # Your GameEngine instance.
var difficulty: int
var ai_tile                       # Instance of ABMinimaxTile.
var monte_carlo_ai                # Instance of MonteCarloInitialMovement.
var human_first: bool = true
var players = []                  # Array of Player objects.
var turn_order = []               # Turn order array.
var first_player_first

#For updating text in colored banners
var p1Tilesleft = 4
var p2Tilesleft = 4

var p1TilesCovered = 1
var p2TilesCovered = 1
# For tracking the tile placement phase.
var tile_round: int = 1
var tile_turn_index: int = 0

# For initial piece placement.
var init_turn_index: int = 0

# For the move phase.
var move_turn_index: int = 0

# Overall game state.
var game_state = GameState.TURN_ORDER

var ai_moved: bool

@onready var ingameui = $InGameUI
func _ready():

	first_player_first = GlobalVars.first_player_moves_first
	game_engine = GameEngine.new()
	var ingameui = $InGameUI
	ingameui.UpdateP1Label("tiles left to Place" + var_to_str(p1Tilesleft) )
	ingameui.UpdateP2Label("tiles left to Place" + var_to_str(p2Tilesleft) )
	
	
	
	# Connect the submit button's pressed signal to our handler.
	
	# Ask the user if they want to go first.

	# Setup the game with the desired difficulty.
	setup_game()  # For example, using difficulty level 3.
func _on_wait_timeout() -> void:
	pass
	
func setup_game():

	var difficulty_level = GlobalVars.difficulty
	print("Difficulty: ", difficulty_level)
	# Set AI parameters based on difficulty.
	var max_depth = 3
	if difficulty_level == 1:
		max_depth = 2
	elif difficulty_level == 2:
		max_depth = 4
	elif difficulty_level == 3:
		max_depth = 6

	# Initialize AI components.
	ai_tile = ABMinimaxTile.new()
	ai_tile.Initialize(max_depth + 5, 2)
	monte_carlo_ai = MonteCarloInitialMovement.new()
	monte_carlo_ai.Initialize(250 * (max_depth / 2), 2)
	monte_carlo_ai.connect("BestInitialPlacementReady", _on_BestInitialPlacementReady)
	monte_carlo_ai.connect("BestMovementReady", _on_BestMovementReady)
	
	# Setup players.
	var human_player = Player.new()
	human_player.Initialize(1, "Human")
	var ai_player = Player.new()
	ai_player.Initialize(2, "AI")
	
	players = [human_player, ai_player]
	turn_order = players.duplicate()  # Copy the array.
	
	

	message_label.text = "Do you want to go first? (y/n)"
	if first_player_first == 1:
		process_input("y")
	else:
		process_input("n")

# This function is called when the submit button is pressed.

# Dispatch the input to the appropriate handler.
func process_input(input_text: String) -> void:
	match game_state:
		GameState.TURN_ORDER:
			process_turn_order(input_text)
		#GameState.INITIAL_PLACEMENT:
			#process_initial_input(input_text)
		# GameState.MOVE_PHASE:
			#process_move_input(input_text)
		_:
			pass

func process_turn_order(input_text: String) -> void:
	human_first = (input_text == "y")
	if not human_first:
		turn_order.reverse()
	message_label.text = "Starting Local PvAI Game..."

	game_engine.StartGame()
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	
	# Transition to tile placement phase.
	game_state = GameState.TILE_PLACEMENT
	tile_round = 1
	tile_turn_index = 0
	start_tile_placement()

#############################################
# Tile Placement Phase
#############################################

func start_tile_placement():
	if tile_round <= 4:
		message_label.text = "Tile Placement Round %d" % tile_round
		tile_turn_index = 0
	
		ingameui.UpdateP1Label("Tiles left to place %d" % p1Tilesleft)
		ingameui.UpdateP2Label("Tiles left to place %d" % p2Tilesleft)
		await process_tile_turn()  # Make sure to await if process_tile_turn is async.
	else:
		# When tile placement rounds are complete, start initial piece placement.

		ingameui.UpdateMainLabel("Conquer")
		game_state = GameState.INITIAL_PLACEMENT
		init_turn_index = 0
		start_initial_piece_placement()

func process_tile_turn():
	# If all players have placed a tile in this round, move to the next round.
	if tile_turn_index >= turn_order.size():
		tile_round += 1
		await start_tile_placement()
		return

	var current_player = turn_order[tile_turn_index]
	print("Player: ", current_player.Id)
	if current_player.Id == 1:
		# Wait for human input.
		message_label.text = "Your turn to place a tile."
		GlobalVars.player_turn = true
	else:
		message_label.text = "AI's turn to place a tile."
		# AI places its tile asynchronously.
		await ai_place_tile()

		# After the AI move, continue processing the next turn.
		await process_tile_turn()

func process_tile_input(q: int, r: int, orientation: int):
	var valid_moves = get_valid()
	var is_valid = false

	# Only process a move if it is valid.
	for move in valid_moves:
		if move["q"] == q and move["r"] == r and move["orientation"] == orientation:
			is_valid = true
			break

	if is_valid:
		game_engine.PlaceTile(1, q, r, orientation)
		$"../boardPlace".play()
		
		ingameui.P1TurnCompleteAnimation()
		
		var state = game_engine.GetCurrentBoardState()
		board.update_from_state(state)
		GlobalVars.player_turn = false
		
		tile_turn_index += 1
		p1Tilesleft -= 1
		# Process the next turn.

		ingameui.UpdateP1Label("Tiles left to place %d" % p1Tilesleft)
		process_tile_turn()
	else:
		message_label.text = "Invalid tile placement. Please try again."

func ai_place_tile():
	var best_tile = ai_tile.GetBestTilePlacement(game_engine)
	
	# Simulate AI thinking time without blocking the engine.
	await get_tree().create_timer(1.0).timeout
	
	$"../boardPlace".play()
	ingameui.P2TurnCompleteAnimation()
	
	game_engine.PlaceTile(2, best_tile["q"], best_tile["r"], best_tile["orientation"])
	message_label.text = "AI placed tile at (%d, %d) with orientation %d" % [best_tile["q"], best_tile["r"], best_tile["orientation"]]
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)

	p2Tilesleft -= 1
	ingameui.UpdateP2Label("Tiles left to place %d" % p2Tilesleft)
	tile_turn_index += 1

#############################################
# Initial Piece Placement Phase
#############################################

func start_initial_piece_placement():
	if init_turn_index < turn_order.size():
		var current_player = turn_order[init_turn_index]
		if current_player.Id == 1:
			message_label.text = "Your turn for initial piece placement. Enter (q r):"
			GlobalVars.player_turn = true
		else:
			ai_place_initial_piece()
			
	else:
		# After initial placements, move to the move phase.
		game_state = GameState.MOVE_PHASE
		move_turn_index = 0
		start_move_phase()

func process_initial_input(q: int, r: int):
	var valid_moves = get_valid()
	var is_valid = false
	
	for move in valid_moves:
		if move["q"] == q and move["r"] == r:
			is_valid = true
			break

	if is_valid:
		ingameui.P1TurnCompleteAnimation()
		$"../tokenMove".play()
		game_engine.PlaceInitialPieces(1, q, r)
		var state = game_engine.GetCurrentBoardState()
		board.update_from_state(state)
		GlobalVars.player_turn = false
		init_turn_index += 1
		start_initial_piece_placement()
	else:
		message_label.text = "Invalid input. Enter (q r):"

func ai_place_initial_piece():
	monte_carlo_ai.StartBestInitialPlacement(game_engine)

func _on_BestInitialPlacementReady(result):
	game_engine.PlaceInitialPieces(2, result["q"], result["r"])
	ingameui.P2TurnCompleteAnimation()
	$"../tokenMove".play()
	
	
	message_label.text = "AI placed its initial piece at (%d, %d)" % [result["q"], result["r"]]
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	
	# Now advance the initial placement turn index
	init_turn_index += 1
	start_initial_piece_placement()


#############################################
# Move Phase
#############################################

func start_move_phase():
	message_label.text = "Move Phase - Starting Moves"
	move_turn_index = 0
	process_move_turn()

func process_move_turn():
	# Check win conditions.
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	if game_engine.CheckForWin():
		end_game()
		return

	var current_player = turn_order[move_turn_index]
	# Check if the current player can move.
	if not game_engine.CanPlayerMove(current_player.Id):
		message_label.text = "%s cannot move. Game over." % current_player.name	
		if not game_engine.CanPlayerMove(1):
			message_label.text = "AI cannot move. Game over."
			ingameui.UpdateMainLabel("Player 2 wins!")
			ingameui.P1LoseAnimation()
		else:
			ingameui.UpdateMainLabel("Player 1 wins!")
			ingameui.P2LoseAnimation()
		end_game()
		return

	if current_player.Id == 1:
		message_label.text = "Your turn to move. Enter (startRow startCol count directionIndex):"
		GlobalVars.player_turn = true
		# print(get_valid())
	else:
		ai_move()

func process_move_input(q: int, r: int, num_pieces: int, direction: int):
	print(q, " ", r, " ",num_pieces, " ", direction)
	game_engine.MovePieces(1, q, r, num_pieces, direction)
	$"../tokenMove".play()
	ingameui.P1TurnCompleteAnimation()
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	GlobalVars.player_turn = false
	move_turn_index = (move_turn_index + 1) % turn_order.size()
	process_move_turn()


func ai_move():
	if not game_engine.CanPlayerMove(2):
		message_label.text = "AI cannot move. Game over."
		ingameui.UpdateMainLabel("Player 1 wins!")
		end_game()
		return
	monte_carlo_ai.StartBestMovement(game_engine)
	
func _on_BestMovementReady(result):
	game_engine.MovePieces(2, result["startRow"], result["startCol"], result["count"], result["directionIndex"])
	ingameui.P2TurnCompleteAnimation()
	$"../tokenMove".play()
	message_label.text = "AI moved %d pieces from (%d, %d) in direction %d" % [result["count"], result["startRow"], result["startCol"], result["directionIndex"]]
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	
	# Now advance the turn after the AI move completes.
	move_turn_index = (move_turn_index + 1) % turn_order.size()
	process_move_turn()

func end_game():
	game_state = GameState.GAME_OVER
	message_label.text = "Game Over. Final Board State:"
	
	GlobalVars.player_turn = false
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	
	# Display game over scene
	var game_over_scene_packed = load("res://Scenes/Menus/game_over_screen.tscn")
	var game_over_scene_instance = game_over_scene_packed.instantiate()
	add_child(game_over_scene_instance)
	
	#get_tree().change_scene_to_file("res://Scenes/Menus/game_over_screen.tscn")

func get_valid():
	match game_state:
		GameState.TILE_PLACEMENT:
			return game_engine.GodotGetValidTile()
		GameState.INITIAL_PLACEMENT:
			return game_engine.GodotGetValidInitial()
		GameState.MOVE_PHASE:
			return game_engine.GodotGetValidMoves(1)
		_:
			pass
