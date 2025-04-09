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
		print("local ", gamemode)
		$MenuTemplate/VBoxContainer/Join/Error.visible = false
		$MenuTemplate/VBoxContainer/Host/Error.visible = false
		GlobalVars.is_local_pvp = true
		get_tree().change_scene_to_file("res://Scenes/pvp_board.tscn")
	elif gamemode == 1:
		$MenuTemplate/VBoxContainer/Host/Error.visible = false
		var join_text = $MenuTemplate/VBoxContainer/Join/JoinName
		var error_label = $MenuTemplate/VBoxContainer/Join/Error
		var raw_text: String = join_text.text
		var cleaned_text: String = raw_text.strip_edges().to_lower()
		
		if cleaned_text == "":
			error_label.visible = true
		else:
			error_label.visible = false
			GlobalVars.game_code = cleaned_text
			GlobalVars.is_host = false
			get_tree().change_scene_to_file("res://Scenes/online_board.tscn")
	
	elif gamemode == 2:
		$MenuTemplate/VBoxContainer/Join/Error.visible = false
		var host_text = $MenuTemplate/VBoxContainer/Host/HostName
		var error_label = $MenuTemplate/VBoxContainer/Host/Error
		var raw_text: String = host_text.text
		var cleaned_text: String = raw_text.strip_edges().to_lower()
		
		if cleaned_text == "":
			error_label.visible = true
		else:
			error_label.visible = false
			GlobalVars.game_code = cleaned_text
			GlobalVars.is_host = true
			get_tree().change_scene_to_file("res://Scenes/online_board.tscn")
	
	
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
