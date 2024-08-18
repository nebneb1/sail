extends RigidBody3D

const ACCEL : float = 700.0
const MAX_VEL : float = 12.0 #10.0
var max_vel : float= MAX_VEL
var cur_accel : Vector3 = Vector3()
var target_vel : Vector3 = Vector3()
var target_rot : float = 0.0
var input : Vector2 = Vector2()
var new_rot : float = 0.0
var cur_rot : float = 0.0
var cur_lean : float = 0.0

func _integrate_forces(state):
	input = Vector2(
		Input.get_action_strength("down")-Input.get_action_strength("up"),
		Input.get_action_strength("left")-Input.get_action_strength("right"),
	)
	input = input.normalized()
	if input.x != 0:
		target_vel.x += input.x * ACCEL * state.step
	else:
		target_vel.x = move_toward(target_vel.x, 0.0, state.step * ACCEL * 2)
	if input.y != 0:
		target_vel.z += input.y * ACCEL * state.step
	else:
		target_vel.z = move_toward(target_vel.z, 0.0, state.step * ACCEL * 2)
	var pl_vel = Vector2(target_vel.x, target_vel.z)
	if pl_vel.length() >= max_vel:
		pl_vel = pl_vel.normalized() * max_vel
		target_vel.x = pl_vel.x 
		target_vel.z = pl_vel.y
	match_target_vel(state.step)

func match_target_vel(delta : float):
	var error = -(linear_velocity - target_vel) * delta * 100
	apply_central_force(error)
