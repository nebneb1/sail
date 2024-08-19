extends Node3D

var tween: Tween
var notifying : bool = false
@onready var anima = $AnimatedSprite3D
var init_parent = null
var init_pos : Vector3 = Vector3()
var transition_to : String = ""
var previous_trans_speed : float = 0.0
var current_noti : String = "null"
func _ready():
	show()
	anima.scale = Vector3(0, 0, 0)
	anima.animation = "null"
	init_parent = get_parent()
	init_pos = position
	top_level = true
	
	
func _process(delta):
	if top_level:
		global_position = init_parent.global_position + init_pos
	
func noti(noti_name, speed = 0.0):
	if noti_name == current_noti:
		return
	current_noti = noti_name
	if noti_name == "null":
		if speed != 0.0:
			if is_instance_valid(tween):
				tween.kill()
			tween = create_tween()
			if is_instance_valid(tween):
				tween.connect("finished",Callable(self,"tween_finished"))
				tween.tween_property(anima, "scale", Vector3(0, 0, 0), speed).from_current()
				transition_to = ""
		else:
			anima.scale = Vector3(0, 0, 0)
		return
	if anima.animation == "null":
		anima.play(noti_name)
		if speed != 0.0:
			if is_instance_valid(tween):
				tween.kill()
			tween = create_tween()
			if is_instance_valid(tween):
				tween.connect("finished",Callable(self,"tween_finished"))
				tween.tween_property(anima, "scale", Vector3(1, 1, 1), speed).from_current()
				transition_to = ""
		else:
			anima.scale = Vector3(1, 1, 1)
	else:
		if speed != 0.0:
			if is_instance_valid(tween):
				tween.kill()
			tween = create_tween()
			if is_instance_valid(tween):
				tween.tween_property(anima, "scale", Vector3(0, 0, 0), speed).from_current()
				tween.connect("finished",Callable(self,"tween_finished"))
				transition_to = noti_name
				previous_trans_speed = speed
		else:
			anima.scale = Vector3(1, 1, 1)
			anima.play(noti_name)
			
func is_notifying():
	return false if anima.scale.length() == 0 else true

func tween_finished():
	if anima.scale.length() == 0:
		if transition_to == "":
			anima.play("null")
		else:
			tween = create_tween()
			tween.tween_property(anima, "scale", Vector3(1, 1, 1), previous_trans_speed).from(Vector3(0, 0, 0))
			anima.play(transition_to)
			transition_to = ""
	else:
		pass
