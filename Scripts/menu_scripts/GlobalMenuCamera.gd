extends Node

var camera_position: Vector3 = Vector3.ZERO
var camera_rotation: Vector3 = Vector3.ZERO
var has_saved_camera_state = false  # Flag to check if a state is stored

func save_camera(position: Vector3, rotation: Vector3):
	camera_position = position
	camera_rotation = rotation
	has_saved_camera_state = true

func load_camera():
	return { 
		"position": camera_position, 
		"rotation": camera_rotation, 
		"has_state": has_saved_camera_state
	}
