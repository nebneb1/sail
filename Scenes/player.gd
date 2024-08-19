extends RigidBody3D

const ACCEL : float = 100.0
const MAX_VEL : float = 8.0 #10.0
var max_vel : float= MAX_VEL
var cur_accel : Vector3 = Vector3()
var target_vel : Vector3 = Vector3()
var input : Vector2 = Vector2()
var vel_pid : Vec3PID = Vec3PID.new(100.0, 0.0, 0.0, 0.0)

@export_node_path("Camera3D") var camera_path
var camera : Camera3D = null
var cam_rot_y : float

var on_ground := false
var just_left_ground := false 
@export var y_movement : bool = true 

func _ready():
	#Global.player = self
	camera = get_node(camera_path)
	
func _integrate_forces(state):
	input = Vector2(
		Input.get_action_strength("down")-Input.get_action_strength("up"),
		Input.get_action_strength("left")-Input.get_action_strength("right"),
	)
	cam_rot_y = (camera.global_rotation - global_rotation).y
	input = input.rotated(-cam_rot_y + PI/2)
	input = input.normalized()
	if y_movement:
		if on_ground or global_position.y < 0:
			if Input.is_action_just_pressed("jump"):
				$JumpTimer.start(0.02)
				just_left_ground = true
				linear_velocity.y = 15
		on_ground = false
		var contact = false
		for b in range(0, state.get_contact_count()):
			var body = state.get_contact_collider(b)
			var body_dir = state.get_contact_local_normal(b).dot(Vector3(0, 1, 0))
			if body_dir > 0.5:
				on_ground = true
				contact = true
		if $JumpCast.is_colliding():
			var floor = $JumpCast.get_collider()
			if floor is AnimatableBody3D: # attempt to get body moving the guy maybe
				target_vel += Vector3(floor.speed * cos(floor.direction * PI/180), 0, floor.speed * sin(floor.direction * PI/180))
			
		if $JumpCast.is_colliding():
			if $JumpCast.get_collision_normal().dot(Vector3(0, 1, 0)) > 0.5 and linear_velocity.y < 0:
				on_ground = true
		if on_ground:
			gravity_scale = 0 
		else:
			gravity_scale = 3
	if input.x != 0:
		if on_ground or global_position.y < 0:
			target_vel.x += input.x * ACCEL * state.step
		else:
			target_vel.x += input.x * 0.05 * ACCEL * state.step
			#target_vel.z = clamp(target_vel.z, -max_vel/4, max_vel/4)
	else:
		target_vel.x = move_toward(target_vel.x, 0.0, state.step * ACCEL * 2)
	if input.y != 0:
		if on_ground or global_position.y < 0:
			target_vel.z += input.y * ACCEL * state.step
		else:
			target_vel.z += input.y * 0.05 * ACCEL * state.step
			#target_vel.z = clamp(target_vel.z, -max_vel/4, max_vel/4)
	else:
		target_vel.z = move_toward(target_vel.z, 0.0, state.step * ACCEL * 2)
	
	var pl_vel = Vector2(target_vel.x, target_vel.z)
	if pl_vel.length() >= max_vel:
		pl_vel = pl_vel.normalized() * max_vel
		#target_vel = target_vel.normalized() * max_vel
		target_vel.x = pl_vel.x 
		target_vel.z = pl_vel.y
	match_target_vel(state.step)
	if global_position.y < 0:
		linear_velocity.y += 40 * state.step * -global_position.y
	
	
func match_target_vel(delta : float):
	var error = vel_pid.step(-(linear_velocity - target_vel), delta)
	apply_central_force(error * Vector3(1, 0, 1))
