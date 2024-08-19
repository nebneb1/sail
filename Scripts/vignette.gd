extends Node2D
const DEFULT = 1.71

@export var smol : bool

func _process(delta: float) -> void:
	if not smol:
		if DisplayServer.window_get_size().x >= 1920:
			show()
		else:
			hide()
	else:
		if DisplayServer.window_get_size().x >= 1920:
			hide()
		else:
			show()
	#else:
		
	global_position = DisplayServer.window_get_size()/2.0
	#var scl = DisplayServer.window_get_size().x / 1920
	#scale = Vector2(scl, scl)
