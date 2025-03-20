extends Sprite2D

var isHovered = false

func _input(event: InputEvent) -> void:
#	if event is InputEventMouseMotion:
#		if get_rect().has_point(to_local(event.position)):
#			if not isHovered:
#				isHovered = true
#				modulate = Color(1.2, 1.2, 1.2)
#				scale = Vector2(1.1, 1.1)
#			else:
#				if isHovered:
#					isHovered = false
#					modulate = Color(1, 1, 1)
#					scale = Vector2(1, 1)


	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_rect().has_point(to_local(event.position)):
			get_tree().change_scene_to_file("res://Scenes/Menus/player_difficulty.tscn")
	
	
