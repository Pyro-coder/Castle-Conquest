extends CanvasLayer

@onready var title = $PanelContainer/MarginContainer/VBoxContainer/Title
@onready var restartBtn = $PanelContainer/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/RestartBtn
@onready var menuBtn = $PanelContainer/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/MenuBtn
@onready var quitBtn = $PanelContainer/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer2/QuitBtn
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	AudioPlayer.stop()
	audio_player.play()


func set_title(winner: int):
	match winner:
		0:
			title.text = "Its a Tie"
		1:
			title.text = "Player One Conquers All!"
		2:
			title.text = "Player Two Conquers All!"
		

func _on_restart_btn_pressed() -> void:
	AudioPlayer.play()
	if GlobalVars.is_local_pvp:
		get_tree().change_scene_to_file("res://Scenes/pvp_board.tscn")
	elif GlobalVars.is_local_pvai:
		get_tree().change_scene_to_file("res://Scenes/Menus/coinflipscreen.tscn")
	else:
		print("not sure how to restart a networked game, but you'll probably want to add that here in the game_over_screen.gd")


func _on_menu_btn_pressed() -> void:
	AudioPlayer.play_menu_music()
	AudioPlayer.play()
	
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	
func _on_quit_btn_pressed() -> void:
	get_tree().quit()
	
