extends Control

# Define game states.
enum GameState { TURN_ORDER, TILE_PLACEMENT, INITIAL_PLACEMENT, MOVE_PHASE, GAME_OVER }

# UI nodes.
@onready var message_label: Label = $MessageLabel
@onready var wait_timer: Timer = $Wait_Timer
@onready var board: Node = get_parent()  # Expects an update_from_state(state) method.
@onready var ingameui: Control = $InGameUI
@onready var NetworkManager = $"../NetworkManager"  # Adjust path as needed

# Game objects.
var game_engine: GameEngine  # Your game engine instance.
var players: Array = []      # Array of Player objects.
var turn_order: Array = []   # Turn order array.

# Game variables.
var p1Tilesleft: int = 4
var p2Tilesleft: int = 4
var p1TilesCovered: int = 0
var p2TilesCovered: int = 0

# Phase tracking variables.
var tile_round: int = 1
var tile_turn_index: int = 0
var init_turn_index: int = 0
var move_turn_index: int = 0

var game_state = GameState.TURN_ORDER

# Helper: Return our role (1 for host, 2 for client) based on MultiplayerAPI.
func get_local_player_role() -> int:
	var uid = get_tree().get_multiplayer().get_unique_id()
	# Assume host (server) always has uid == 1.
	return 1 if uid == 1 else 2

# Helper: Return the remote peer's id.
func get_remote_peer_id() -> int:
	if get_local_player_role() == 1:
		var peers = get_tree().get_multiplayer().get_peers()
		if peers.size() > 0:
			return peers[0]
		else:
			return 0  # No remote peer found.
	else:
		return 1

func _ready() -> void:
	print("GameController ready on unique id: ", get_tree().get_multiplayer().get_unique_id())
	NetworkManager.connect("connection_established", Callable(self, "setup_game"))
	message_label.text = "Waiting for network connection..."

#############################################
# SETUP GAME – Host always goes first.
#############################################
func setup_game() -> void:
	# For PvP, force the host to be Player 1.
	var human_player = Player.new()
	human_player.Initialize(1, "Player 1")
	var remote_player = Player.new()
	remote_player.Initialize(2, "Player 2")
	players = [human_player, remote_player]
	turn_order = players.duplicate()
	
	game_engine = GameEngine.new()
	game_engine.StartGame()
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	
	# Transition to tile placement.
	game_state = GameState.TILE_PLACEMENT
	tile_round = 1
	tile_turn_index = 0
	start_tile_placement_phase()

#############################################
# TILE PLACEMENT PHASE
#############################################
func start_tile_placement_phase() -> void:
	if tile_round <= 4:
		message_label.text = "Tile Placement Round %d" % tile_round
		tile_turn_index = 0
		ingameui.UpdateP1Label("Tiles left: %d" % p1Tilesleft)
		ingameui.UpdateP2Label("Tiles left: %d" % p2Tilesleft)
		update_tile_turn()
	else:
		ingameui.UpdateMainLabel("Place Initial Pieces")
		game_state = GameState.INITIAL_PLACEMENT
		init_turn_index = 0
		start_initial_placement_phase()

func update_tile_turn() -> void:
	if tile_turn_index >= turn_order.size():
		tile_round += 1
		start_tile_placement_phase()
		return
	
	var current_player = turn_order[tile_turn_index]
	print("Tile Placement turn: round %d, turn index %d, local role %d" % [tile_round, tile_turn_index, get_local_player_role()])
	if current_player.Id == get_local_player_role():
		message_label.text = "Your turn to place a tile."
		GlobalVars.player_turn = true
	else:
		message_label.text = "Waiting for opponent's tile placement..."
		GlobalVars.player_turn = false

# Called when the local player places a tile.
func process_tile_input(q: int, r: int, orientation: int) -> void:
	if not GlobalVars.player_turn:
		return
	var valid_moves = get_valid()
	var is_valid = false
	for move in valid_moves:
		if move["q"] == q and move["r"] == r and move["orientation"] == orientation:
			is_valid = true
			break
	if is_valid:
		update_tile_placement(q, r, orientation)
		tile_turn_index += 1
		update_tile_turn()  # Advance the turn.
	else:
		message_label.text = "Invalid tile placement. Try again."

# Unified update function for tile placement.
func update_tile_placement(q: int, r: int, orientation: int) -> void:
	# Local update.
	game_engine.PlaceTile(get_local_player_role(), q, r, orientation)
	$"../boardPlace".play()
	if get_local_player_role() == 1:
		p1Tilesleft -= 1
		ingameui.erase_blue_hex(p1Tilesleft)
		ingameui.UpdateP1Label("Tiles left: %d" % p1Tilesleft)
	else:
		p2Tilesleft -= 1
		ingameui.erase_red_hex(p2Tilesleft)
		ingameui.UpdateP2Label("Tiles left: %d" % p2Tilesleft)
	board.update_from_state(game_engine.GetCurrentBoardState())
	
	# Send RPC to remote peer.
	var remote_id = get_remote_peer_id()
	if remote_id != 0:
		rpc_id(remote_id, "rpc_tile_placement", q, r, orientation)
	else:
		print("Warning: No remote peer found when sending tile placement.")

@rpc("any_peer", "reliable")
func rpc_tile_placement(q: int, r: int, orientation: int) -> void:
	var remote_role = 2 if get_local_player_role() == 1 else 1
	print("Remote RPC (tile placement) received on uid %s: q=%d, r=%d, orient=%d" % [str(get_tree().get_multiplayer().get_unique_id()), q, r, orientation])
	game_engine.PlaceTile(remote_role, q, r, orientation)
	$"../boardPlace".play()
	board.update_from_state(game_engine.GetCurrentBoardState())
	if remote_role == 1:
		p1Tilesleft -= 1
		ingameui.erase_blue_hex(p1Tilesleft)
		ingameui.UpdateP1Label("Tiles left: %d" % p1Tilesleft)
	else:
		p2Tilesleft -= 1
		ingameui.erase_red_hex(p2Tilesleft)
		ingameui.UpdateP2Label("Tiles left: %d" % p2Tilesleft)
	# Advance the turn counter and update UI accordingly.
	tile_turn_index += 1
	update_tile_turn()

#############################################
# INITIAL PIECE PLACEMENT PHASE
#############################################
func start_initial_placement_phase() -> void:
	if init_turn_index < turn_order.size():
		var current_player = turn_order[init_turn_index]
		if current_player.Id == get_local_player_role():
			message_label.text = "Your turn for initial placement. Enter (q r):"
			GlobalVars.player_turn = true
		else:
			message_label.text = "Waiting for opponent's initial placement..."
			GlobalVars.player_turn = false
	else:
		game_state = GameState.MOVE_PHASE
		move_turn_index = 0
		start_move_phase()

func process_initial_input(q: int, r: int) -> void:
	var valid_moves = get_valid()
	var is_valid = false
	for move in valid_moves:
		if move["q"] == q and move["r"] == r:
			is_valid = true
			break
	if is_valid:
		update_initial_placement(q, r)
		init_turn_index += 1
		start_initial_placement_phase()
	else:
		message_label.text = "Invalid input. Try again."

# Unified update for initial placement.
func update_initial_placement(q: int, r: int) -> void:
	game_engine.PlaceInitialPieces(get_local_player_role(), q, r)
	$"../tokenMove".play()
	if get_local_player_role() == 1:
		ingameui.P1TurnCompleteAnimation()
	else:
		ingameui.P2TurnCompleteAnimation()
	board.update_from_state(game_engine.GetCurrentBoardState())
	var remote_id = get_remote_peer_id()
	if remote_id != 0:
		rpc_id(remote_id, "rpc_initial_placement", q, r)
	else:
		print("Warning: No remote peer found when sending initial placement.")

@rpc("any_peer", "reliable")
func rpc_initial_placement(q: int, r: int) -> void:
	var remote_role = 2 if get_local_player_role() == 1 else 1
	print("Remote RPC (initial placement) received: q=%d, r=%d" % [q, r])
	game_engine.PlaceInitialPieces(remote_role, q, r)
	$"../tokenMove".play()
	if remote_role == 1:
		ingameui.P1TurnCompleteAnimation()
	else:
		ingameui.P2TurnCompleteAnimation()
	board.update_from_state(game_engine.GetCurrentBoardState())
	
	# Increment the turn index and update phase so the other player can move.
	init_turn_index += 1
	start_initial_placement_phase()


#############################################
# MOVE PHASE
#############################################
func start_move_phase() -> void:
	message_label.text = "Move Phase - Starting Moves"
	move_turn_index = 0
	update_move_turn()

func update_move_turn() -> void:
	var state = game_engine.GetCurrentBoardState()
	board.update_from_state(state)
	if game_engine.CheckForWin():
		end_game()
		return
	
	var current_player = turn_order[move_turn_index]
	print("Move Phase turn: Player %d on local role %d" % [current_player.Id, get_local_player_role()])
	if not game_engine.CanPlayerMove(current_player.Id):
		message_label.text = "%s cannot move. Game over." % current_player.name
		end_game()
		return
	
	if current_player.Id == get_local_player_role():
		message_label.text = "Your turn to move. Enter (startRow startCol count directionIndex):"
		GlobalVars.player_turn = true
	else:
		message_label.text = "Waiting for opponent's move..."
		GlobalVars.player_turn = false

func process_move_input(q: int, r: int, num_pieces: int, direction: int) -> void:
	var current_player = turn_order[move_turn_index]
	if current_player.Id == get_local_player_role():
		update_move(q, r, num_pieces, direction)
		move_turn_index = (move_turn_index + 1) % turn_order.size()
		update_move_turn()

# Unified update for moves.
func update_move(q: int, r: int, num_pieces: int, direction: int) -> void:
	game_engine.MovePieces(get_local_player_role(), q, r, num_pieces, direction)
	$"../tokenMove".play()
	if get_local_player_role() == 1:
		p1TilesCovered += 1
		ingameui.UpdateP1Label("Tiles Conquered %d" % p1TilesCovered)
	else:
		p2TilesCovered += 1
		ingameui.UpdateP2Label("Tiles Conquered %d" % p2TilesCovered)
	board.update_from_state(game_engine.GetCurrentBoardState())
	GlobalVars.player_turn = false
	var remote_id = get_remote_peer_id()
	if remote_id != 0:
		rpc_id(remote_id, "rpc_move", q, r, num_pieces, direction)
	else:
		print("Warning: No remote peer found when sending move.")

@rpc("any_peer", "reliable")
func rpc_move(q: int, r: int, num_pieces: int, direction: int) -> void:
	var remote_role = 2 if get_local_player_role() == 1 else 1
	print("Remote RPC (move) received: q=%d, r=%d, pieces=%d, dir=%d" % [q, r, num_pieces, direction])
	game_engine.MovePieces(remote_role, q, r, num_pieces, direction)
	$"../tokenMove".play()
	if remote_role == 1:
		p1TilesCovered += 1
		ingameui.UpdateP1Label("Tiles Conquered %d" % p1TilesCovered)
	else:
		p2TilesCovered += 1
		ingameui.UpdateP2Label("Tiles Conquered %d" % p2TilesCovered)
	board.update_from_state(game_engine.GetCurrentBoardState())
	
	# Increment the move turn index and update the UI for the next turn.
	move_turn_index = (move_turn_index + 1) % turn_order.size()
	update_move_turn()


#############################################
# GAME OVER
#############################################
func end_game() -> void:
	game_state = GameState.GAME_OVER
	message_label.text = "Game Over. Final Board State:"
	GlobalVars.player_turn = false
	board.update_from_state(game_engine.GetCurrentBoardState())
	var game_over_scene_packed = load("res://Scenes/Menus/game_over_screen.tscn")
	var game_over_scene_instance = game_over_scene_packed.instantiate()
	add_child(game_over_scene_instance)
	game_over_scene_instance.set_title(p1TilesCovered > p2TilesCovered)
	self.visible = false

func get_valid() -> Array:
	match game_state:
		GameState.TILE_PLACEMENT:
			return game_engine.GodotGetValidTile()
		GameState.INITIAL_PLACEMENT:
			return game_engine.GodotGetValidInitial()
		GameState.MOVE_PHASE:
			return game_engine.GodotGetValidMoves(turn_order[move_turn_index].Id)
		_:
			return []
