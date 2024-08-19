extends MeshInstance3D

@export var target : Node3D
#func _ready():
	#Debug.track($CPUParticles3D, "global_position")
	
func _process(delta: float):
	global_position = Vector3(target.global_position.x, global_position.y, target.global_position.z)
	#global_rotation = target.global_rotation
