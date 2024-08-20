extends Node3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().quit()
