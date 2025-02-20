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

	get_tree().change_scene_to_file("res://Scenes/board.tscn")
	
