extends VideoStreamPlayer

func _process(_delta):
	if get_parent().get_parent().get_parent().is_visible_in_tree():
		visible = true
	else:
		visible = false
