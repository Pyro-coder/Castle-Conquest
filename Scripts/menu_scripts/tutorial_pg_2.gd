extends Control
@onready var menuTemplate = $MenuTemplate
@onready var mainBtn = $MenuTemplate/HBoxContainer/mainBtn

@onready var backBtn = $MenuTemplate/HBoxContainer/BackButton
@onready var nextBtn = $MenuTemplate/HBoxContainer/NextButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_btn_pressed() -> void:
	menuTemplate.buttonPress()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


func _on_main_btn_mouse_entered() -> void:
	mainBtn.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	mainBtn.scale = Vector2(1.1, 1.1)


func _on_main_btn_mouse_exited() -> void:
	mainBtn.modulate = Color(1, 1, 1)     # Reset to original color
	mainBtn.scale = Vector2(1, 1)
	
func _on_back_button_pressed() -> void:
	menuTemplate.buttonPress()

	get_tree().change_scene_to_file("res://Scenes/Menus/tutorial_pg_1.tscn")
	

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_next_button_pressed() -> void:
	menuTemplate.buttonPress()

	get_tree().change_scene_to_file("res://Scenes/Menus/tutorial_pg_3.tscn")


func _on_back_button_mouse_entered() -> void:
	backBtn.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	backBtn.scale = Vector2(1.1, 1.1)  


func _on_back_button_mouse_exited() -> void:
	backBtn.modulate = Color(1, 1, 1)     # Reset to original color
	backBtn.scale = Vector2(1, 1)


func _on_next_button_mouse_entered() -> void:
	nextBtn.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	nextBtn.scale = Vector2(1.1, 1.1) 


func _on_next_button_mouse_exited() -> void:
	nextBtn.modulate = Color(1, 1, 1)     # Reset to original color
	nextBtn.scale = Vector2(1, 1)
