extends Node3D

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			#Global.game_started = true
			get_tree().change_scene_to_file("res://Scenes/main.tscn")
