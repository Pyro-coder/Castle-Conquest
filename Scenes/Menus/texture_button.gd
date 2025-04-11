extends TextureButton

func _on_texture_button_pressed():
	get_parent().toggle_pause()
