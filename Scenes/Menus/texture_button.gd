extends TextureButton

func pauseButnPressed():
	var pause_node = get_node("../Control")
	if pause_node:
		pause_node._is_paused = !pause_node.is_paused
