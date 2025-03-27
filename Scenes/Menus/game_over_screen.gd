extends CanvasLayer

@onready var title = $PanelContainer/MarginContainer/VBoxContainer/Title
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	AudioPlayer.stop()
	audio_player.play()

func set_title(win: bool):
	if win:
		title.text = "Victory is yours!"
	else:
		title.text = "You have been conquered"


func _on_restart_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/coinflipscreen.tscn")


func _on_quit_btn_pressed() -> void:
	get_tree().quit()
