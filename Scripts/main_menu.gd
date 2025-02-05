extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/player_mode_menu.tscn")


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tutorial_pg_1.tscn")


func _on_about_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/about_page.tscn")
	
