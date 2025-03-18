extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var bannerlabel = $"Banners-large-cropped-main/bannerlabel"
var flipcount = 0

func _input(event):
	if event.is_action_pressed("ui_select") && flipcount == 0:
		var result  = coin_flip()
		result = 1 
		if result == 0:
			print("heads")
			get_node("coinflip").get_child(0).play("flipheads")
			if !(get_node("coinflip").get_child(0).is_playing()):
				bannerlabel.text = "Player 1 moves first" 
				
		else:
			print("tails")
			get_node("coinflip").get_child(0).play("fliptails")
			
			if !(get_node("coinflip").get_child(0).is_playing()):
				bannerlabel.text = "Player 1 moves last"  
					
			

func coin_flip():
	return floor(randf_range(0, 2))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
