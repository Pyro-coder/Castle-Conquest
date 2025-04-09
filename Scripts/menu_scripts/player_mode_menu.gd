extends Control

@onready var onePlayer = $MenuTemplate/VBoxContainer/OnePlayerButton
@onready var twoPlayer = $MenuTemplate/VBoxContainer/TwoPlayerButton
@onready var backBtn = $MenuTemplate/HBoxContainer/BackButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if onePlayer:
		onePlayer.connect("mouse_entered", playerHovered)
		onePlayer.connect("mouse_exited", playerExited)
	if twoPlayer:
		twoPlayer.connect("mouse_entered", twoPlayerHovered)
		twoPlayer.connect("mouse_exited", twoPlayerExited)
	if backBtn:
		backBtn.connect("mouse_entered", backBtnHovered)
		backBtn.connect("mouse_exited", backBtnExited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	$MenuTemplate.buttonPress()
	
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_one_player_button_pressed() -> void:
	$MenuTemplate.buttonPress()
	
	get_tree().change_scene_to_file("res://Scenes/Menus/player_difficulty.tscn")

func _on_two_player_button_pressed() -> void:
	$MenuTemplate.buttonPress()
	
	get_tree().change_scene_to_file("res://Scenes/Menus/game_join_menu.tscn")
	
	
func playerHovered() -> void:
	onePlayer.modulate = Color(0.8, 0.6, 0.2)
	onePlayer.scale = Vector2(1.1, 1.1)
		
func playerExited() -> void: 
	onePlayer.modulate = Color(1, 1, 1)
	onePlayer.scale = Vector2(1, 1)
		
func twoPlayerHovered() -> void:
	twoPlayer.modulate = Color(0.8, 0.6, 0.2)
	twoPlayer.scale = Vector2(1.1, 1.1)

func twoPlayerExited() -> void: 
	twoPlayer.modulate = Color(1, 1, 1)
	twoPlayer.scale = Vector2(1, 1)

func backBtnHovered() -> void: 
	if backBtn:
		backBtn.modulate = Color(1.2, 1.2, 1.2)
		backBtn.scale = Vector2(1.1, 1.1)

func backBtnExited() -> void: 
	if backBtn:
		backBtn.modulate = Color(1, 1, 1)
		backBtn.scale = Vector2(1, 1)
