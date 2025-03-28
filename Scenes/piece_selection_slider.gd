extends HSlider

@onready var control_node = get_parent().get_parent()
@onready var numPieces_label = get_parent().get_node("NumPiecesLabel")

var timer: Timer  # Timer to control processing intervals
var interval: float = 0.05

func _ready() -> void:
	# Create and configure the timer
	timer = Timer.new()
	timer.wait_time = interval
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	
	# Connect the slider's value_changed signal to update the label
	self.connect("value_changed", Callable(self, "_on_value_changed"))
	numPieces_label.text = str(GlobalVars.num_pieces_selected)

func _on_timer_timeout() -> void:
	if GlobalVars.castle_selected == true:
		get_parent().show()
		if control_node.game_state == control_node.GameState.MOVE_PHASE and GlobalVars.player_turn or control_node.game_state == control_node.GameState.MOVE_PHASE and GlobalVars.is_local_pvp:
			var valid_moves = control_node.get_valid()
			
			# Filter moves matching GlobalVars.hex_selected (assume x corresponds to startRow and y to startCol)
			var filtered_moves = []
			for move in valid_moves:
				if move["startRow"] == GlobalVars.hex_selected.x and move["startCol"] == GlobalVars.hex_selected.y:
					filtered_moves.append(move)
			
			# If there are matching moves, update the slider's range and default value
			if filtered_moves.size() > 0:
				var max_count = 0
				for move in filtered_moves:
					if move["count"] > max_count:
						max_count = move["count"]
				# Set slider range (assuming a minimum of 1)
				self.min_value = 1
				self.max_value = max_count
	else:
		get_parent().hide()


func _on_value_changed(val: float) -> void:
	# Update the number of pieces selected for processing and the label
	
	
	GlobalVars.num_pieces_selected = int(val)
	numPieces_label.text = str(GlobalVars.num_pieces_selected)
