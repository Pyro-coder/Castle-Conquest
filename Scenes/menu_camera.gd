extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var camera_state = GlobalMenuCamera.load_camera()
	if camera_state["has_state"]:
		global_position = camera_state["position"]
		global_rotation_degrees = camera_state["rotation"]
		print("Loaded camera state from memory")

func _exit_tree():
	GlobalMenuCamera.save_camera(global_position, global_rotation_degrees)
	print("Saved camera state in memory")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
