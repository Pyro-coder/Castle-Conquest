extends Control

@onready var play_button = $MenuTemplate/VBoxContainer3/PlayButton
@onready var settings_button = $MenuTemplate/VBoxContainer3/SettingsButton
@onready var tutorial_button = $MenuTemplate/VBoxContainer3/TutorialButton
@onready var about_button = $MenuTemplate/HBoxContainer/AboutButton
@onready var quit_button = $MenuTemplate/HBoxContainer/QuitButton
@onready var menu_template = $MenuTemplate
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_globals()
	AudioPlayer.play_menu_music()
	if play_button:
		play_button.connect("mouse_entered", _on_play_button_mouse_entered)
		play_button.connect("mouse_exited", _on_play_button_mouse_exited)
	if settings_button:
		settings_button.connect("mouse_entered", _on_settings_button_mouse_entered)
		settings_button.connect("mouse_exited", _on_settings_button_mouse_exited)
	if tutorial_button:
		tutorial_button.connect("mouse_entered", _on_tutorial_button_mouse_entered)
		tutorial_button.connect("mouse_exited", _on_tutorial_button_mouse_exited)
	if about_button:
		about_button.connect("mouse_entered", _on_about_button_mouse_entered)
		about_button.connect("mouse_exited", _on_about_button_mouse_exited)
	if quit_button:
		quit_button.connect("mouse_entered", _on_quit_button_mouse_entered)
		quit_button.connect("mouse_exited", _on_quit_button_mouse_exited)
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	menu_template.buttonPress()
	
	get_tree().change_scene_to_file("res://Scenes/Menus/player_mode_menu.tscn")


func _on_settings_button_pressed() -> void:
	menu_template.buttonPress()
	
	get_tree().change_scene_to_file("res://Scenes/Menus/settings.tscn")


func _on_quit_button_pressed() -> void:
	menu_template.buttonPress()
	
	get_tree().quit()


func _on_tutorial_button_pressed() -> void:
	menu_template.buttonPress()
	
	get_tree().change_scene_to_file("res://Scenes/Menus/tutorial_contents.tscn")


func _on_about_button_pressed() -> void:
	menu_template.buttonPress()
	
	get_tree().change_scene_to_file("res://Scenes/Menus/about_page.tscn")
	
	
#Button Hover Effects
func _on_play_button_mouse_entered() -> void:
	if play_button:
		play_button.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
		play_button.scale = Vector2(1.1, 1.1)        # Slightly scale up the button

func _on_play_button_mouse_exited() -> void:
	if play_button:
		play_button.modulate = Color(1, 1, 1)     # Reset to original color
		play_button.scale = Vector2(1, 1)         # Reset to original scale

func _on_settings_button_mouse_entered() -> void:
	if settings_button:
		settings_button.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
		settings_button.scale = Vector2(1.1, 1.1)        # Slightly scale up the button

func _on_settings_button_mouse_exited() -> void:
	if settings_button:
		settings_button.modulate = Color(1, 1, 1)     # Reset to original color
		settings_button.scale = Vector2(1, 1)      
		
func _on_tutorial_button_mouse_entered() -> void:
	if tutorial_button:
		tutorial_button.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
		tutorial_button.scale = Vector2(1.1, 1.1)        # Slightly scale up the button

func _on_tutorial_button_mouse_exited() -> void:
	if tutorial_button:
		tutorial_button.modulate = Color(1, 1, 1)     # Reset to original color
		tutorial_button.scale = Vector2(1, 1)         # Reset to original sc
	
func _on_about_button_mouse_entered() -> void:
	if about_button:
		about_button.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
		about_button.scale = Vector2(1.1, 1.1)        # Slightly scale up the button

func _on_about_button_mouse_exited() -> void:
	if about_button:
		about_button.modulate = Color(1, 1, 1)     # Reset to original color
		about_button.scale = Vector2(1, 1)         # Reset to original sc


func _on_quit_button_mouse_entered() -> void:
	if quit_button:
		quit_button.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
		quit_button.scale = Vector2(1.1, 1.1)        # Slightly scale up the button

func _on_quit_button_mouse_exited() -> void:
	if quit_button:
		quit_button.modulate = Color(1, 1, 1)     # Reset to original color
		quit_button.scale = Vector2(1, 1)         # Reset to original sc
		
		
func reset_globals():
	print("Resetting global vars")
	GlobalVars.difficulty = 3
	GlobalVars.player_turn = false
	GlobalVars.hex_selected = Vector2i()
	GlobalVars.castle_selected = false
	GlobalVars.castle_coords = Vector2i()
	GlobalVars.valid_move_tiles = Array()
	GlobalVars.num_pieces_selected = 8
	GlobalVars.first_player_moves_first = 0
	GlobalVars.is_coin_done_spinning = 1
	GlobalVars.is_local_pvp = false
	GlobalVars.is_host = true
	GlobalVars.game_code = ""
