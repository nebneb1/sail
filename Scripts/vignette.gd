extends Node2D

func _process(delta: float) -> void:
	global_position = DisplayServer.window_get_size()/2.0
