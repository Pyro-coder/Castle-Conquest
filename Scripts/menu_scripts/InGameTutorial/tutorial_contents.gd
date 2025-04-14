extends Control
@onready var menuTemplate = $MenuTemplate

#@onready var backBtn = $MenuTemplate/HBoxContainer/BackButton
@onready var nextBtn = $MenuTemplate/HBoxContainer/NextButton
@onready var mainBtn = $MenuTemplate/HBoxContainer/mainBtn

@onready var modeSelect = $MenuTemplate/VBoxContainer/ModeSelection
@onready var coinFlip = $MenuTemplate/VBoxContainer/CoinFlip
@onready var boardPlace = $MenuTemplate/VBoxContainer/BoardPlacement
@onready var boardRotate = $MenuTemplate/VBoxContainer/BoardRotation
@onready var initialPlace = $MenuTemplate/VBoxContainer/InitialPlacement
@onready var movement = $MenuTemplate/VBoxContainer/TokenMovement
@onready var ending =  $MenuTemplate/VBoxContainer/EndingGame



# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	menuTemplate.buttonPress()
	self.hide()
	

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_next_button_pressed() -> void:
	menuTemplate.buttonPress()
	$"../TutorialPg1".show()
	self.hide()

#func _on_back_button_mouse_entered() -> void:
	#backBtn.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	#backBtn.scale = Vector2(1.1, 1.1)  
#
#
#func _on_back_button_mouse_exited() -> void:
	#backBtn.modulate = Color(1, 1, 1)     # Reset to original color
	#backBtn.scale = Vector2(1, 1)


func _on_next_button_mouse_entered() -> void:
	nextBtn.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	nextBtn.scale = Vector2(1.1, 1.1) 


func _on_next_button_mouse_exited() -> void:
	nextBtn.modulate = Color(1, 1, 1)     # Reset to original color
	nextBtn.scale = Vector2(1, 1)


func _on_mode_selection_mouse_entered() -> void:
	modeSelect.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	modeSelect.scale = Vector2(1.1, 1.1) 


func _on_mode_selection_mouse_exited() -> void:
	modeSelect.modulate = Color(1, 1, 1)     # Reset to original color
	modeSelect.scale = Vector2(1, 1)

func _on_mode_selection_pressed() -> void:
	menuTemplate.buttonPress()
	$"../TutorialPg1".show()
	self.hide()

func _on_coin_flip_pressed() -> void:
	menuTemplate.buttonPress()
	$"../TutorialPg2".show()
	self.hide()
	


func _on_coin_flip_mouse_entered() -> void:
	coinFlip.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	coinFlip.scale = Vector2(1.1, 1.1)


func _on_coin_flip_mouse_exited() -> void:
	coinFlip.modulate = Color(1, 1, 1)     # Reset to original color
	coinFlip.scale = Vector2(1, 1)

func _on_board_placement_pressed() -> void:
	menuTemplate.buttonPress()
	$"../TutorialPg3".show()
	self.hide()



func _on_board_placement_mouse_entered() -> void:
	boardPlace.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	boardPlace.scale = Vector2(1.1, 1.1)


func _on_board_placement_mouse_exited() -> void:
	boardPlace.modulate = Color(1, 1, 1)     # Reset to original color
	boardPlace.scale = Vector2(1, 1)


func _on_board_rotation_pressed() -> void:
	menuTemplate.buttonPress()
	$"../TutorialPg4".show()
	self.hide()


func _on_board_rotation_mouse_entered() -> void:
	boardRotate.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	boardRotate.scale = Vector2(1.1, 1.1)

func _on_board_rotation_mouse_exited() -> void:
	boardRotate.modulate = Color(1, 1, 1)     # Reset to original color
	boardRotate.scale = Vector2(1, 1)

func _on_initial_placement_pressed() -> void:
	menuTemplate.buttonPress()
	$"../TutorialPg5".show()
	self.hide()



func _on_initial_placement_mouse_entered() -> void:
	initialPlace.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	initialPlace.scale = Vector2(1.1, 1.1)

func _on_initial_placement_mouse_exited() -> void:
	initialPlace.modulate = Color(1, 1, 1)     # Reset to original color
	initialPlace.scale = Vector2(1, 1)


func _on_token_movement_pressed() -> void:
	menuTemplate.buttonPress()
	$"../TutorialPg6".show()
	self.hide()



func _on_token_movement_mouse_entered() -> void:
	movement.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	movement.scale = Vector2(1.1, 1.1)

func _on_token_movement_mouse_exited() -> void:
	movement.modulate = Color(1, 1, 1)     # Reset to original color
	movement.scale = Vector2(1, 1)

func _on_ending_game_pressed() -> void:
	menuTemplate.buttonPress()
	$"../TutorialPg7".show()
	self.hide()



func _on_ending_game_mouse_entered() -> void:
	ending.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	ending.scale = Vector2(1.1, 1.1)

func _on_ending_game_mouse_exited() -> void:
	ending.modulate = Color(1, 1, 1)     # Reset to original color
	ending.scale = Vector2(1, 1)


func _on_main_btn_pressed() -> void:
	menuTemplate.buttonPress()
	self.hide()


func _on_main_btn_mouse_entered() -> void:
	mainBtn.modulate = Color(1.2, 1.2, 1.2) # Slightly brighten the button
	mainBtn.scale = Vector2(1.1, 1.1)


func _on_main_btn_mouse_exited() -> void:
	mainBtn.modulate = Color(1, 1, 1)     # Reset to original color
	mainBtn.scale = Vector2(1, 1)
