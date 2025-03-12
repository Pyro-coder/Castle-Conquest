extends Control

var background = preload("res://Scenes/world.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/player_mode_menu.tscn")
	
	


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_conquer_button_pressed() -> void:
	var group = $MenuTemplate/VBoxContainer/Peasant.button_group
	var selected = group.get_pressed_button()

	if selected == null:
		# No button is selected. Optionally, show a message to the user.
		print("Please select a difficulty before continuing.")
		return

	match selected.name:
		"Peasant":
			Difficulty.difficulty = 1
		"Knight":
			Difficulty.difficulty = 2
		"King":
			Difficulty.difficulty = 3

	get_tree().change_scene_to_file("res://Scenes/board.tscn")
	
