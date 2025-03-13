extends Camera3D
class_name FixedAngleCamera

@export var move_speed: float = 10.0
@export var smooth_factor: float = 5.0  # Higher value = faster interpolation

var dynamic_min_x: float
var dynamic_max_x: float
var dynamic_min_z: float
var dynamic_max_z: float

var target_position: Vector3

@onready var control_node = get_node("../PV_AI_Control")

func _ready() -> void:
	# Keep the camera angle/position you want:
	rotation_degrees = Vector3(-70.0, 90.0, 0.0)
	position = Vector3(-45.0, 13.0, -50.0)
	target_position = position

func _physics_process(delta: float) -> void:
	if control_node.tile_round == 1:
		return
		
	_update_dynamic_bounds()

	# 1) Gather input for WASD / Arrow keys (The directions are also tilted 90 degrees)
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):    # W or Up Arrow
		input_dir.x -= 3
	if Input.is_action_pressed("ui_down"):  # S or Down Arrow
		input_dir.x += 3
	if Input.is_action_pressed("ui_left"):  # A or Left Arrow
		input_dir.y += 3
	if Input.is_action_pressed("ui_right"): # D or Right Arrow
		input_dir.y -= 3

	# 2) Move strictly in global XZ, ignoring camera rotation
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		# "input_dir.y" moves along global Z, and "input_dir.x" along global X.
		var move_vec = Vector3(input_dir.x, 0.0, input_dir.y) * move_speed * delta
		target_position += move_vec

		# 3) Clamp the target position so it cannot pan away from your pieces
		target_position.x = clamp(target_position.x, dynamic_min_x, dynamic_max_x)
		target_position.z = clamp(target_position.z, dynamic_min_z, dynamic_max_z)
		
	# 4) Smoothly interpolate the camera's current position toward the target position
	position = position.lerp(target_position, smooth_factor * delta)

func _update_dynamic_bounds() -> void:
	# Dynamically compute bounding box around all "Pieces" in the scene
	var piece_nodes = get_tree().get_nodes_in_group("Pieces")
	if piece_nodes.is_empty():
		# If no pieces exist, clamp to some default
		dynamic_min_x = -100
		dynamic_max_x =  100
		dynamic_min_z = -100
		dynamic_max_z =  100
		return

	var min_px = INF
	var max_px = -INF
	var min_pz = INF
	var max_pz = -INF

	for piece in piece_nodes:
		var piece_pos = piece.global_transform.origin
		min_px = min(min_px, piece_pos.x)
		max_px = max(max_px, piece_pos.x)
		min_pz = min(min_pz, piece_pos.z)
		max_pz = max(max_pz, piece_pos.z)

	# Add some margin so the camera doesn't sit right on the edge
	var margin = 10.0
	dynamic_min_x = min_px - margin + 15
	dynamic_max_x = max_px + margin - 3
	dynamic_min_z = min_pz - margin + 10
	dynamic_max_z = max_pz + margin - 10
