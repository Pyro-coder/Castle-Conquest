extends Control

@onready var audio_player: AudioStreamPlayer = $TextureRect/AudioStreamPlayer

func _ready() -> void:
	audio_player.play()
	audio_player.finished.connect(audioFinished)

func audioFinished() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
