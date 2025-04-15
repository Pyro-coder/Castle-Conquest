extends Node3D

# We'll assume there's an AnimationPlayer node directly under Dragon2
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var path_follow: PathFollow3D = get_parent() as PathFollow3D

func _ready():
	if GlobalVars.saved_dragon_anim_state:
		var data = GlobalVars.saved_dragon_anim_state
		if data.has("animation"):
			anim_player.play(data["animation"])
			anim_player.seek(data["position"], true)
			if not data["playing"]:
				anim_player.stop()
		if data.has("progress_ratio"):
			path_follow.progress_ratio = data["progress_ratio"]


func _exit_tree():
	if path_follow:
		GlobalVars.saved_dragon_anim_state = {
			"animation": anim_player.current_animation,
			"position": anim_player.current_animation_position,
			"playing": anim_player.is_playing(),
			"progress_ratio": path_follow.progress_ratio
		}
