extends Control

# Define game states to control the flow.
enum GameState { TURN_ORDER, TILE_PLACEMENT, INITIAL_PLACEMENT, MOVE_PHASE, GAME_OVER }

# UI nodes.
@onready var message_label: Label = $MessageLabel
@onready var wait_timer = $Wait_Timer
@onready var board: Node = get_parent()  # Assumes the parent node contains an update_from_state(state) method.
@onready var ingameui = $InGameUI

# Game objects.
var game_engine: GameEngine  # Your GameEngine instance.
var difficulty: int
var players = []            # Array of Player objects.
var turn_order = []         # Turn order array.

# For updating text in colored banners.
var p1Tilesleft = 4
var p2Tilesleft = 4
var p1TilesCovered = 1
var p2TilesCovered = 1

# Phase tracking variables.
var tile_round: int = 1
var tile_turn_index: int = 0
var init_turn_index: int = 0
var move_turn_index: int = 0

# Overall game state.
var game_state = GameState.TURN_ORDER

func _ready():
	# Create game engine.
	game_engine = GameEngine.new()
	ingameui.UpdateP1Label("Tiles left to Place: " + str(p1Tilesleft))
	ingameui.UpdateP2Label("Tiles left to Place: " + str(p2Tilesleft))
	
	GlobalVars.is_local_pvp = true
	# Setup the game with fixed turn order: Player 1 always goes first.
	setup_game()

func _on_wait_timeout() -> void:
	pass

func setup_game():
	# Setup players.
	var human_player1 = Player.new()
	human_player1.Initialize(1, "Player 1")
	var human_player2 = Player.new()
	human_player2.Initialize(2, "Player 2")
	
	players = [human_player1, human_player2]
	turn_order = players.duplicate()  # Turn order fixed as [Player 1, Player 2].
	
	# Bypass any player turn order selection; Player 1 always goes first.
	message_label.text = "Starting Local PvP Game..."
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
		ingameui.UpdateP1Label("Tiles left to place: %d" % p1Tilesleft)
		ingameui.UpdateP2Label("Tiles left to place: %d" % p2Tilesleft)
		process_tile_turn()
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
		start_tile_placement()
		return

	var current_player = turn_order[tile_turn_index]
	# Set global turn flag: true for Player 1, false for Player 2.
	GlobalVars.player_turn = (current_player.Id == 1)
	message_label.text = "Player %d's turn to place a tile." % current_player.Id
	# Wait for current player's input (which should trigger process_tile_input).

func process_tile_input(q: int, r: int, orientation: int):
	var valid_moves = get_valid()
	var is_valid = false

	# Only process a move if it is valid.
	for move in valid_moves:
		if move["q"] == q and move["r"] == r and move["orientation"] == orientation:
			is_valid = true
			break

	if is_valid:
		var current_player = turn_order[tile_turn_index]
		game_engine.PlaceTile(current_player.Id, q, r, orientation)
		$"../boardPlace".play()
		if current_player.Id == 1:
			ingameui.P1TurnCompleteAnimation()
			p1Tilesleft -= 1
			ingameui.UpdateP1Label("Tiles left to place: %d" % p1Tilesleft)
			ingameui.erase_blue_hex(p1Tilesleft)

		else:
			ingameui.P2TurnCompleteAnimation()
			p2Tilesleft -= 1
			ingameui.erase_red_hex(p2Tilesleft)
			ingameui.UpdateP2Label("Tiles left to place: %d" % p2Tilesleft)
		var state = game_engine.GetCurrentBoardState()
		board.update_from_state(state)
		GlobalVars.player_turn = false
		tile_turn_index += 1
		process_tile_turn()
	else:
		message_label.text = "Invalid tile placement. Please try again."

#############################################
# Initial Piece Placement Phase
#############################################
func start_initial_piece_placement():
	if init_turn_index < turn_order.size():
		var current_player = turn_order[init_turn_index]
		GlobalVars.player_turn = (current_player.Id == 1)
		message_label.text = "Player %d's turn for initial piece placement. Enter (q r):" % current_player.Id
		# Wait for player's input (which should trigger process_initial_input).
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
		var current_player = turn_order[init_turn_index]
		game_engine.PlaceInitialPieces(current_player.Id, q, r)
		$"../tokenMove".play()
		if current_player.Id == 1:
			ingameui.P1TurnCompleteAnimation()
			ingameui.UpdateP1Label("Tiles Conquered: %d" % p1TilesCovered)

		else:
			ingameui.P2TurnCompleteAnimation()
			ingameui.UpdateP2Label("Tiles Conquered: %d" % p2TilesCovered)

		var state = game_engine.GetCurrentBoardState()
		board.update_from_state(state)
		GlobalVars.player_turn = false
		init_turn_index += 1
		start_initial_piece_placement()
	else:
		message_label.text = "Invalid input. Enter (q r):"

#############################################
# Move Phase
#############################################
func start_move_phase():
	message_label.text = "Move Phase - Starting Moves"
	move_turn_index = 0
	process_move_turn()

func process_move_turn():
	# Update board state and check for win.
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	if game_engine.CheckForWin():
		end_game()
		return

	var current_player = turn_order[move_turn_index]
	if not game_engine.CanPlayerMove(current_player.Id):
		message_label.text = "%s cannot move. Game over." % current_player.name
		if not game_engine.CanPlayerMove(1):
			message_label.text = "Player 1 cannot move. Game over."
			ingameui.UpdateMainLabel("Player 2 wins!")
			ingameui.P1LoseAnimation()
		else:
			ingameui.UpdateMainLabel("Player 1 wins!")
			ingameui.P2LoseAnimation()
		end_game()
		return

	GlobalVars.player_turn = (current_player.Id == 1)
	message_label.text = "Player %d's turn to move. Enter (startRow startCol count directionIndex):" % current_player.Id
	# Wait for player's input (which should trigger process_move_input).

func process_move_input(q: int, r: int, num_pieces: int, direction: int):
	var current_player = turn_order[move_turn_index]
	game_engine.MovePieces(current_player.Id, q, r, num_pieces, direction)
	$"../tokenMove".play()
	if current_player.Id == 1:
		p1TilesCovered += 1
		ingameui.P1TurnCompleteAnimation()
		ingameui.UpdateP2Label("Tiles Conquered: %d" % p1TilesCovered)

	else:
		p2TilesCovered+=1
		ingameui.P2TurnCompleteAnimation()
		ingameui.UpdateP2Label("Tiles Conquered: %d" % p1TilesCovered)

	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	GlobalVars.player_turn = false
	move_turn_index = (move_turn_index + 1) % turn_order.size()
	process_move_turn()

func end_game():
	game_state = GameState.GAME_OVER
	message_label.text = "Game Over. Final Board State:"
	GlobalVars.player_turn = false
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	
	# Display game over scene.
	var game_over_scene_packed = load("res://Scenes/Menus/game_over_screen.tscn")
	var game_over_scene_instance = game_over_scene_packed.instantiate()
	add_child(game_over_scene_instance)

func get_valid():
	match game_state:
		GameState.TILE_PLACEMENT:
			return game_engine.GodotGetValidTile()
		GameState.INITIAL_PLACEMENT:
			return game_engine.GodotGetValidInitial()
		GameState.MOVE_PHASE:
			# Pass the current player's ID to get valid moves.
			return game_engine.GodotGetValidMoves(turn_order[move_turn_index].Id)
		_:
			return []
