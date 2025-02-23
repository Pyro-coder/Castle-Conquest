extends TextEdit

func _ready():
	focus_entered.connect(_on_focus_entered)

func _on_focus_entered():
	var parent_node = get_parent()
	if parent_node is CheckBox:
		parent_node.button_pressed = true
