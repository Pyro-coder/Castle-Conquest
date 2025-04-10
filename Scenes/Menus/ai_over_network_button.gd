extends Button

func _ready():
	# Get a reference to the button
	var button = $"."

	# Hide the button visually (either method works)
	#my_button.visible = false
	button.modulate = Color(1, 1, 1, 0)

	# Ensure the button remains clickable
	button.disabled = false
