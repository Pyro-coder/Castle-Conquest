extends Control

var background = preload("res://Scenes/world.tscn")

@onready var backBtn = $MenuTemplate/HBoxContainer/BackButton
@onready var conquerBtn = $MenuTemplate/HBoxContainer/ConquerButton
@onready var peasant = $MenuTemplate/VBoxContainer/Peasant
@onready var knight = $MenuTemplate/VBoxContainer/Knight
@onready var king = $MenuTemplate/VBoxContainer/King


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		if backBtn: 
			backBtn.connect("mouse_entered", on_backBtn_mouse_entered)
			backBtn.connect("mouse_exited", on_backBtn_mouse_exited)
		if conquerBtn: 
			conquerBtn.connect("mouse_entered", on_conquerBtn_mouse_entered)
			conquerBtn.connect("mouse_exited", on_conquerBtn_mouse_exited)
		if peasant:
			peasant.connect("mouse_entered", on_peasant_mouse_entered)
			peasant.connect("mouse_exited", on_peasant_mouse_exited)
		if knight: 
			knight.connect("mouse_entered", on_knight_hovered)
			knight.connect("mouse_exited", on_knight_exited)
		if king:
			king.connect("mouse_entered", on_king_hovered)
			king.connect("mouse_exited", on_king_exited)
		



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
			GlobalVars.difficulty = 1
			AudioPlayer.play_easy_music()
		"Knight":
			GlobalVars.difficulty = 2
			AudioPlayer.play_medium_music()
			
		"King":
			GlobalVars.difficulty = 3
			AudioPlayer.play_hard_music()
			

	get_tree().change_scene_to_file("res://Scenes/Menus/coinflipscreen.tscn")
	
func on_backBtn_mouse_entered() -> void:
	if backBtn:
		backBtn.modulate = Color(1.2, 1.2, 1.2) 
		backBtn.scale = Vector2(1.1, 1.1)   
		
func on_backBtn_mouse_exited() -> void:
	if backBtn:
		backBtn.modulate = Color(1, 1, 1)
		backBtn.scale = Vector2(1, 1)
		
func on_conquerBtn_mouse_entered() -> void:
	if conquerBtn:
		conquerBtn.modulate = Color(1.2, 1.2, 1.2)
		conquerBtn.scale = Vector2(1.1, 1.1)

func on_conquerBtn_mouse_exited() -> void:
	if conquerBtn:
		conquerBtn.modulate = Color(1, 1, 1)
		conquerBtn.scale = Vector2(1, 1)

func on_peasant_mouse_entered() -> void:
	if peasant:
		peasant.modulate = Color(1.2, 1.2, 1.2)
		peasant.scale = Vector2(1.1, 1.1)

func on_peasant_mouse_exited() -> void:
	if peasant:
		peasant.modulate = Color(1, 1, 1)
		peasant.scale = Vector2(1, 1)
		
func on_knight_hovered() -> void:
	if knight:
		knight.modulate = Color(1.2, 1.2, 1.2)
		knight.scale = Vector2(1.1, 1.1)

func on_knight_exited() -> void:
	if knight:
		knight.modulate = Color(1, 1, 1)
		knight.scale = Vector2(1, 1)
		
func on_king_hovered() -> void:
	if king:
		king.modulate = Color(1.2, 1.2, 1.2)
		king.scale = Vector2(1.1, 1.1)

func on_king_exited() -> void:
	if king:
		king.modulate = Color(1, 1, 1)
		king.scale = Vector2(1, 1)
		
