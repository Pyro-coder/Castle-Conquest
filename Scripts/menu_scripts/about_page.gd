extends Control

@onready var backBtn = $MenuTemplate/HBoxContainer/BackButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if backBtn:
		backBtn.connect("mouse_entered", backBtnHvrd)
		backBtn.connect("mouse_exited", backBtnExt)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
func backBtnHvrd() -> void:
	if backBtn:
		backBtn.scale = Vector2(1.1, 1.1)
		
func backBtnExt() -> void:
	if backBtn:
		backBtn.scale = Vector2(1, 1)
