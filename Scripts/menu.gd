extends Node3D

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			#Global.game_started = true
			get_parent().call_deferred("switch_scene", "game", 1.0, 2.0, "pinhole")
