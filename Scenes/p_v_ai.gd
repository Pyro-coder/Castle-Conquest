extends Control

# Define game states to control the flow.
enum GameState { TURN_ORDER, TILE_PLACEMENT, INITIAL_PLACEMENT, MOVE_PHASE, GAME_OVER }

# UI nodes.
@onready var message_label: Label = $MessageLabel
@onready var input_field: LineEdit = $InputField
@onready var submit_button: Button = $SubmitButton
@onready var board: Node = get_parent()  # Assumes the parent node contains an update_from_state(state) method.

# Game and AI objects.
var game_engine: GameEngine       # Your GameEngine instance.
var difficulty: int
var ai_tile                       # Instance of ABMinimaxTile.
var monte_carlo_ai                # Instance of MonteCarloInitialMovement.
var human_first: bool = true
var players = []                  # Array of Player objects.
@export var turn_order = []               # Turn order array.

# For tracking the tile placement phase.
@export var tile_round: int = 1
@export var tile_turn_index: int = 0

# For initial piece placement.
var init_turn_index: int = 0

# For the move phase.
var move_turn_index: int = 0

# Overall game state.
@export var game_state = GameState.TURN_ORDER

func _ready():
	game_engine = GameEngine.new()
	# Connect the submit button's pressed signal to our handler.
	submit_button.pressed.connect(_on_submit_pressed)
	# Setup the game with the desired difficulty.
	setup_game(Difficulty.difficulty)  # For example, using difficulty level 3.

func setup_game(difficulty_level: int):
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
	ai_tile.Initialize(max_depth, 2)
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
	
	# Ask the user if they want to go first.
	message_label.text = "Do you want to go first? (y/n)"
	input_field.text = ""
	input_field.show()
	submit_button.show()

# This function is called when the submit button is pressed.
func _on_submit_pressed():
	var input_text = input_field.text.strip_edges().to_lower()
	# Clear the input field.
	input_field.text = ""
	# Dispatch input based on the current game state.
	process_input(input_text)

# Dispatch the input to the appropriate handler.
func process_input(input_text: String) -> void:
	match game_state:
		GameState.TURN_ORDER:
			process_turn_order(input_text)
		GameState.INITIAL_PLACEMENT:
			process_initial_input(input_text)
		GameState.MOVE_PHASE:
			process_move_input(input_text)
		_:
			pass

func process_turn_order(input_text: String) -> void:
	human_first = (input_text == "y")
	if not human_first:
		turn_order.reverse()
	message_label.text = "Starting Local PvAI Game..."
	input_field.hide()
	submit_button.hide()
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
		process_tile_turn()
	else:
		# When tile placement rounds are complete, start initial piece placement.
		game_state = GameState.INITIAL_PLACEMENT
		init_turn_index = 0
		start_initial_piece_placement()

func process_tile_turn():
	# If all players have placed a tile in this round, move to the next round.
	if tile_turn_index >= turn_order.size():
		tile_round += 1
		start_tile_placement()
		return
	
	var current_player = turn_order[tile_turn_index]
	if current_player.Id == 1:
		# Wait for human input.
		message_label.text = "Your turn to place a tile. Enter (q r orientation):"
		input_field.show()
		submit_button.show()
	else:
		# AI places its tile.
		ai_place_tile()
		tile_turn_index += 1
		# Continue to process the next turn.
		process_tile_turn()

func process_tile_input(q: int, r: int, orientation: int):
	var valid_moves = get_valid()
	var is_valid = false
	
	# Only process a move if it is valid
	for move in valid_moves:
		if move["q"] == q and move["r"] == r and move["orientation"] == orientation:
			is_valid = true
			break
	if is_valid:
		game_engine.PlaceTile(1, q, r, orientation)
		var state = game_engine.GetCurrentBoardState()
		board.update_from_state(state)
		input_field.hide()
		submit_button.hide()
		tile_turn_index += 1
		process_tile_turn()
	else:
		message_label.text = "Invalid tile placement. Please try again."
	

func ai_place_tile():
	var best_tile = ai_tile.GetBestTilePlacement(game_engine)
	game_engine.PlaceTile(2, best_tile["q"], best_tile["r"], best_tile["orientation"])
	message_label.text = "AI placed tile at (%d, %d) with orientation %d" % [best_tile["q"], best_tile["r"], best_tile["orientation"]]
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)

#############################################
# Initial Piece Placement Phase
#############################################

func start_initial_piece_placement():
	if init_turn_index < turn_order.size():
		var current_player = turn_order[init_turn_index]
		if current_player.Id == 1:
			message_label.text = "Your turn for initial piece placement. Enter (q r):"
			input_field.show()
			submit_button.show()
			print(get_valid())
		else:
			ai_place_initial_piece()
	else:
		# After initial placements, move to the move phase.
		game_state = GameState.MOVE_PHASE
		move_turn_index = 0
		start_move_phase()

func process_initial_input(input_text: String):
	var tokens = input_text.split(" ")
	if tokens.size() == 2 and tokens[0].is_valid_int() and tokens[1].is_valid_int():
		game_engine.PlaceInitialPieces(1, tokens[0].to_int(), tokens[1].to_int())
		var state = game_engine.GetCurrentBoardState()
		board.update_from_state(state)
		input_field.hide()
		submit_button.hide()
		init_turn_index += 1
		start_initial_piece_placement()
	else:
		message_label.text = "Invalid input. Enter (q r):"

func ai_place_initial_piece():
	monte_carlo_ai.StartBestInitialPlacement(game_engine)

func _on_BestInitialPlacementReady(result):
	game_engine.PlaceInitialPieces(2, result["q"], result["r"])
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
	if game_engine.CheckForWin():
		end_game()
		return

	var current_player = turn_order[move_turn_index]
	# Check if the current player can move.
	if not game_engine.CanPlayerMove(current_player.Id):
		message_label.text = "%s cannot move. Game over." % current_player.name
		end_game()
		return

	if current_player.Id == 1:
		message_label.text = "Your turn to move. Enter (startRow startCol count directionIndex):"
		input_field.show()
		submit_button.show()
		print(get_valid())
	else:
		ai_move()

func process_move_input(input_text: String):
	var tokens = input_text.split(" ")
	if tokens.size() == 4 and tokens[0].is_valid_int() and tokens[1].is_valid_int() and tokens[2].is_valid_int() and tokens[3].is_valid_int():
		game_engine.MovePieces(1, tokens[0].to_int(), tokens[1].to_int(), tokens[2].to_int(), tokens[3].to_int())
		var state = game_engine.GetCurrentBoardState()
		board.update_from_state(state)
		input_field.hide()
		submit_button.hide()
		move_turn_index = (move_turn_index + 1) % turn_order.size()
		process_move_turn()
	else:
		message_label.text = "Invalid input. Enter (startRow startCol count directionIndex):"

func ai_move():
	if not game_engine.CanPlayerMove(2):
		message_label.text = "AI cannot move. Game over."
		end_game()
		return
	monte_carlo_ai.StartBestMovement(game_engine)
	
func _on_BestMovementReady(result):
	game_engine.MovePieces(2, result["startRow"], result["startCol"], result["count"], result["directionIndex"])
	message_label.text = "AI moved %d pieces from (%d, %d) in direction %d" % [result["count"], result["startRow"], result["startCol"], result["directionIndex"]]
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	
	# Now advance the turn after the AI move completes.
	move_turn_index = (move_turn_index + 1) % turn_order.size()
	process_move_turn()

func end_game():
	game_state = GameState.GAME_OVER
	message_label.text = "Game Over. Final Board State:"
	input_field.hide()
	submit_button.hide()
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)

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
