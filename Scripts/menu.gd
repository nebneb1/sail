extends Node3D

func _ready() -> void:
	if Global.save_file_exists():
		$Control2/RichTextLabel2.text = "[center][wave amp=10.0][tornado radius=2.0 freq=1.0] press  any  key  to  contintue ..."
		Global.saved = true
	else:
		$Control2/RichTextLabel2.text = "[center][wave amp=10.0][tornado radius=2.0 freq=1.0] press  any  key  to  start ..."

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			#Global.game_started = true
			get_parent().call_deferred("switch_scene", "game", 1.0, 2.0, "pinhole")
