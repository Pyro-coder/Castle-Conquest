extends CSGBox3D

@export var clouds_to_spawn : int = 3
@export var cloud_scene_path : String # Export a String to hold the path.
var _cloud : PackedScene

func _ready():
	_cloud = load(cloud_scene_path) as PackedScene # Load the scene from the path.
	if _cloud == null:
		print("Error: Failed to load cloud scene from path:", cloud_scene_path)
		return
	spawn_clouds()

var rng = RandomNumberGenerator.new()

func spawn_clouds():
	var spawn_distance = 5.0
	while clouds_to_spawn >= 0:
		clouds_to_spawn -= 1

		var x : float = rng.randf_range(size.x / 2, -size.x / 2)
		var y : float = rng.randf_range(size.y / 2, -size.y / 2)
		var z : float = rng.randf_range(size.z / 2, -size.z / 2)

		var spawn_pos : Vector3 = Vector3(x, y, z)

		var cloud = _cloud.instantiate()
		add_child(cloud)
		cloud.global_position = self.global_position + spawn_pos
