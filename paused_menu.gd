extends Control

@onready var helpBtn = $GridContainer/helpBtn
@onready var quitBtn = $GridContainer2/QuitBtn
@onready var mainBtn = $GridContainer/Back2MainBtn
@onready var resumeBtn = $GridContainer/ResumeBtn
@onready var buttonGrid = $GridContainer

func _ready() -> void:
	buttonGrid.set_position(Vector2(490,170))
	

func _on_resume_btn_pressed() -> void:
	$buttonPress.play()
	var gameControl = get_parent()
	gameControl.togglePause()
	

func _on_help_btn_pressed() -> void:
	$buttonPress.play()
	
	pass # Replace with function body.

func _on_quit_btn_pressed() -> void:
	$buttonPress.play()
	
	get_tree().quit()

func _on_back_2_main_btn_pressed() -> void:
	#set_paused(false)
	#get_parent().toggle_pause()
	$buttonPress.play()
	
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	
func togglePause():
	get_parent().togglePause()


func _on_help_btn_mouse_entered() -> void:
	helpBtn.modulate = Color(1.2, 1.2, 1.2) 
	helpBtn.scale = Vector2(1.1, 1.1)


func _on_help_btn_mouse_exited() -> void:
	helpBtn.modulate = Color(1, 1, 1)
	helpBtn.scale = Vector2(1, 1)


func _on_back_2_main_btn_mouse_entered() -> void:
	mainBtn.modulate = Color(1.2, 1.2, 1.2) 
	mainBtn.scale = Vector2(1.1, 1.1)


func _on_resume_btn_mouse_entered() -> void:
	resumeBtn.modulate = Color(1.2, 1.2, 1.2) 
	resumeBtn.scale = Vector2(1.1, 1.1)

func _on_quit_btn_mouse_entered() -> void:
	quitBtn.modulate = Color(1.2, 1.2, 1.2) 
	quitBtn.scale = Vector2(1.1, 1.1)


func _on_quit_btn_mouse_exited() -> void:
	quitBtn.modulate = Color(1, 1, 1)
	quitBtn.scale = Vector2(1, 1)


func _on_resume_btn_mouse_exited() -> void:
	resumeBtn.modulate = Color(1, 1, 1)
	resumeBtn.scale = Vector2(1, 1)


func _on_back_2_main_btn_mouse_exited() -> void:
	mainBtn.modulate = Color(1, 1, 1)
	mainBtn.scale = Vector2(1, 1)
