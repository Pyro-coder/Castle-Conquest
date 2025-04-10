extends Button

func _ready() -> void:
	# Connect the "pressed" signal to a local function
	connect("pressed", _on_cancel_pressed)

func _on_cancel_pressed() -> void:
	# Remove (free) the entire NetworkAi scene from the tree
	# Since NetworkAi is the *parent* of this Button
		# Now navigate back to the main menu scene
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	
