extends Control

@onready var node: Node2D =$coinflip
@onready var bannerlabel =$bannerlabel
@onready var wait_timer = $WaitTimer
var sprite 
var flipcount = 0
var result = -1

func _ready() -> void:
	sprite = node.get_child(0)
	wait_timer.connect("timeout", Callable(self, "_on_wait_timeout"))
	sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))





func _input(event):
	if event.is_action_pressed("flip_coin") and flipcount == 0:
		result = coin_flip()
	
		if result == 1:
			
			sprite.play("flipheads")
		else:
		
			sprite.play("fliptails")
		flipcount += 1  # defer logic until animation finishes

func _on_animation_finished() -> void:
	if result == 1:
		bannerlabel.text = "You move first!"
	else:
		bannerlabel.text = "Your opponent moves first!"
	GlobalVars.first_player_moves_first = result
	wait_timer.start()
	


func coin_flip() -> int:
	return floor(randf_range(0, 2))
	
func _on_wait_timeout() -> void:

	GlobalVars.is_coin_done_spinning = 0
	get_tree().change_scene_to_file("res://Scenes/board.tscn")
	
	
