extends TextureButton

func _on_texture_button_pressed():
	var pause_node = get_node("../PausedMenu")
	if pause_node:
		pause_node.toggle_pause()
