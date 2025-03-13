extends Node3D

var coordsfromboard

func setcoords(vector):
	coordsfromboard = vector

func _ready() -> void:
	add_to_group("Pieces")
