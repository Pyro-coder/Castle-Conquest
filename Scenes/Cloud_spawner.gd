extends CSGBox3D

@export var clouds_to_spawn : int = 3
#@export var cloud_scene_path : String # Export a String to hold the path.
var _cloud : PackedScene

func _ready():
	#_cloud = load(cloud_scene_path) as PackedScene # Load the scene from the path.
	#if _cloud == null:
	#	print("Error: Failed to load cloud scene from path:", cloud_scene_path)
	#	return
	spawn_clouds()

var rng = RandomNumberGenerator.new()

func spawn_clouds():
	var spawn_distance = 5.0
	for i in range(clouds_to_spawn):
		var x : float = rng.randf_range(-size.x / 2, size.x / 2)
		var y : float = rng.randf_range(-size.y / 2, size.y / 2)
		var z : float = rng.randf_range(-size.z / 2, size.z / 2)
		
		var spawn_pos : Vector3 = Vector3(x, y, z)
		# Create a cluster of smaller clouds to simulate density
		var cluster_size = rng.randi_range(2, 5) # Number of clouds in a cluster
		for j in range(cluster_size):
			var cloud = _cloud.instantiate()
			add_child(cloud)
			# Randomize scale, rotation, and position within the cluster
			var scale : float = rng.randf_range(0.5, 2.0)
			cloud.scale = Vector3(scale, scale, scale)
			cloud.rotation.y = deg_to_rad(rng.randf_range(0, 360))
			cloud.rotation.x = deg_to_rad(rng.randf_range(-30, 30))
			cloud.rotation.z = deg_to_rad(rng.randf_range(-30, 30))
			
			var cluster_offset : Vector3 = Vector3(
				rng.randf_range(-1.0, 1.0),
				rng.randf_range(-1.0, 1.0),
				rng.randf_range(-1.0, 1.0)
				) * scale * 0.5 # Adjust offset based on scal
			cloud.global_position = self.global_position + spawn_pos + cluster_offset
