extends Node3D


func _ready():
	$Path3D/PathFollow3D/Dragon2.get_child(1).play("Flying")

func _process(delta: float) -> void:
	$Path3D/PathFollow3D.progress += 3 * delta
