extends Sprite2D


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_rect().has_point(to_local(event.position)):
			get_tree().change_scene_to_file("res://Scenes/Menus/game_join_menu.tscn")
