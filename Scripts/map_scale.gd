extends Node3D

const ZOOM_SCALE = 100.0
const SCALE_SPEED = 1.0
const SAFETY_ZONE = 1000.0
var scale_target = Vector3.ONE
var og_scale = Vector3.ONE
var disabled = false

func _ready():
	scale_target = scale
	og_scale = scale

func _process(delta: float):
	disabled = global_position.distance_to(Global.player.global_position) < SAFETY_ZONE or global_position.distance_to(Global.boat.global_position) < SAFETY_ZONE
	if Global.scale_map and not disabled:
		scale_target = Vector3(ZOOM_SCALE,ZOOM_SCALE,ZOOM_SCALE)
	else:
		scale_target = og_scale
	
	scale += (scale_target - scale) * SCALE_SPEED * delta
	print(scale)
	
	
	
	
