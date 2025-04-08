extends Node

var difficulty: int = 3

var player_turn: bool = false

var hex_selected: Vector2i

var castle_selected:bool = false
var castle_coords:Vector2i

var valid_move_tiles:Array

var num_pieces_selected: int = 8

var first_player_moves_first:  int = 0

var is_coin_done_spinning: int = 1

var is_local_pvp: bool = false



var is_host: bool = true


var game_code: String = ""
