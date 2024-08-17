extends Node3D

@export var target : Node3D

func _process(delta: float):
	global_position = target.global_position
