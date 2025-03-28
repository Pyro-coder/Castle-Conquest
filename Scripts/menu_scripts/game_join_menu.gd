extends Control

@onready var backBtn = $MenuTemplate/HBoxContainer/BackButton
@onready var conquerBtn = $MenuTemplate/HBoxContainer/ConquerButton

var gamemode: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if backBtn:
		backBtn.connect("mouse_entered", _on_backbtn_mouse_entered)
		backBtn.connect("mouse_exited", _on_backbtn_mouse_exited)
	if conquerBtn:
		conquerBtn.connect("mouse_entered", _on_conquerbtn_mouse_entered)
		conquerBtn.connect("mouse_exited", _on_conquerbtn_mouse_exited)
	#pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	$MenuTemplate.buttonPress()
	get_tree().change_scene_to_file("res://Scenes/Menus/player_mode_menu.tscn")
	



func _on_quit_button_pressed() -> void:
	$MenuTemplate.buttonPress()
	
	get_tree().quit()


func _on_conquer_button_pressed() -> void:
	$MenuTemplate.buttonPress()
	if gamemode == 0:
		get_tree().change_scene_to_file("res://Scenes/pvp_board.tscn")
	
#Button Hover Effects
func _on_backbtn_mouse_entered() -> void:
	if backBtn:
		backBtn.modulate = Color(1.2, 1.2, 1.2) 
		backBtn.scale = Vector2(1.1, 1.1)   
		
func _on_backbtn_mouse_exited() -> void:
	if backBtn:
		backBtn.modulate = Color(1, 1, 1)
		backBtn.scale = Vector2(1, 1)
		
func _on_conquerbtn_mouse_entered() -> void:
	if conquerBtn:
		conquerBtn.modulate = Color(1.2, 1.2, 1.2)
		conquerBtn.scale = Vector2(1.1, 1.1)

func _on_conquerbtn_mouse_exited() -> void:
	if conquerBtn:
		conquerBtn.modulate = Color(1, 1, 1)
		conquerBtn.scale = Vector2(1, 1)


func _on_local_button_down() -> void:
	$MenuTemplate.buttonPress()
	gamemode = 0

func _on_join_button_down() -> void:
	$MenuTemplate.buttonPress()
	gamemode = 1

func _on_host_button_down() -> void:
	$MenuTemplate.buttonPress()
	gamemode = 2
