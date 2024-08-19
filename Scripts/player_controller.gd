extends CharacterBody3D

const MAX_SPEED = 5.0
const ACCEL = 1.0
const DRAG = .20
var GRAVITY = -9.8*2.0
const TERMINAL_VELOCITY = -20.0
var down_vel = 0.0

const ROT_ACCEL = 5.0
var targ_rotation = 0.0

var vel := Vector2.ZERO

@export var camera_holder : Node3D
@export var camera : Node3D

var interact_name : String
var enable_interact = false
var disable = false
var boat : Node3D
var yvel : float

const JUMP_HEIGHT = 15.0

const GRAV_TIMER = 0.6
var timer = 0.0

#DIALOG
var npcs_in_range : Array = []
var objects_in_range : Array = []
var npc_input_need : DialogEntity = null
var choice_input_need : bool = false

func _ready():
	Debug.track(self, "enable_interact")
	Debug.track(self, "interact_name")
	Debug.track(self, "velocity")
	Global.player = self
	boat = Global.boat
		
func _physics_process(delta: float):
	timer += delta
	if is_on_floor() and global_position.y+1.0 > Global.ground_level: timer = 0
	if global_position.y < Global.ground_level and GRAVITY < 0 and timer >= GRAV_TIMER: 
		GRAVITY = -GRAVITY
		timer = 0.0
	elif global_position.y >= Global.ground_level and GRAVITY > 0 and timer >= GRAV_TIMER: 
		GRAVITY = -GRAVITY
		timer = 0.0
	#print(GRAVITY)
	if not boat: boat = Global.boat
	var dir 
	if not disable:
		dir = Vector2(
		Input.get_action_strength("up")-Input.get_action_strength("down"), 
		Input.get_action_strength("right")-Input.get_action_strength("left")).normalized().rotated(-camera.global_rotation.y - PI/2.0)
	else:
		dir = Vector2.ZERO
	
	if vel.length() <= MAX_SPEED:
		vel += dir*ACCEL
	else:
		vel = vel.normalized() * MAX_SPEED
	
	
	if dir.x == 0.0 and vel.x != 0:
		if vel.x > DRAG: vel.x -= DRAG
		elif vel.x < -DRAG: vel.x += DRAG
		else: vel.x = 0
	
	if dir.y == 0.0 and vel.y != 0:
		if vel.y > DRAG: vel.y -= DRAG
		elif vel.y < -DRAG: vel.y += DRAG
		else: vel.y = 0
	
	if not is_on_floor() or GRAVITY > 0:
		velocity.y += delta*GRAVITY
	
	
	var temp = velocity.y
	velocity = Vector3(vel.x, yvel, vel.y)
	velocity.y = temp
	#global_position += Vector3(vel.x, down_vel, vel.y)
	#$trail.amount = 100 * (Vector3(vel.x, 0, vel.y).length())
	#print($trail.amount)
	if dir.length() != 0:
		targ_rotation = -dir.angle() + PI/2
	rotation.y = lerp_angle(rotation.y, targ_rotation, ROT_ACCEL * delta * 2)
	move_and_slide()
	#velocity = -get_platform_velocity()
	#move_and_slide()
	#print(interact_name)
	if disable:
		match interact_name:
			"main_sheet":
				boat.pull_mainsheet_in = Input.is_action_pressed("down")
				boat.pull_mainsheet_out = Input.is_action_pressed("up")
			"tiller":
				
				boat.tiller_left = Input.is_action_pressed("left")
				boat.tiller_right = Input.is_action_pressed("right")
			"jib_port":
				boat.pull_port_jib_in = Input.is_action_pressed("down")
				boat.pull_port_jib_out = Input.is_action_pressed("up")
			"jib_starboard":
				boat.pull_starboard_jib_in = Input.is_action_pressed("down")
				boat.pull_starboard_jib_out = Input.is_action_pressed("up")
			"anchor":
				if Input.is_action_pressed("down"):
					boat.anchor_down = true
				if Input.is_action_pressed("up"):
					boat.anchor_down = false
					


func _input(event: InputEvent):
	if event.is_action_pressed("jump") and enable_interact:
		disable = true
	elif event.is_action_released("jump") and disable:
		disable = false
		boat.pull_mainsheet_in = false # yeah, i program B)
		boat.pull_mainsheet_out = false
		boat.tiller_left = false
		boat.tiller_right = false
		boat.pull_port_jib_in = false
		boat.pull_port_jib_out = false
		boat.pull_starboard_jib_in = false
		boat.pull_starboard_jib_out = false
	elif event.is_action_pressed("jump") and (is_on_floor() or GRAVITY > 0):
		velocity.y = JUMP_HEIGHT
	elif Input.is_action_just_pressed('interact'):
		if npc_input_need != null:
#			if TEST_MODE:
#				Global.dialog.end_convo(dialog_entity.cur_convo_name)
#			else:
			npc_input_need.process_input()
			#npc_input_need.next_dialog()
			return
		#if dialog_entity.cur_convo_name != "":
			#return
		var npc = null
		var static_npc = null
		for body in npcs_in_range:
			if body.is_in_group('npc'):
				if body.is_convo_avail():
					npc = body
			elif body.is_in_group("static_npc"):
				if body.cur_pot_convo != '':
					static_npc = body
		
		if npc and !npc.dialog_entity.is_interact_locked():
			npc.activate_next_convo()
		elif static_npc and !static_npc.dialog_entity.is_interact_locked():
			static_npc.activate_pot_convo()
			
	if choice_input_need:
		pass
		

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("boat_interact"):
		enable_interact = true
		interact_name = area.name
		area.get_node("noti").noti(area.name)
		
		
	if area.is_in_group("boat"):
		camera_holder.target = Global.boat
		
		#reparent(Global.boat)
#match area.name:
			#"main_sheet":
				#pass
			#"tiller":
				#pass

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("boat_interact"):
		area.get_node("noti").noti("null")
		enable_interact = false
	if area.is_in_group("boat"):
		camera_holder.target = self
		#reparent(Global.game)
		

func disable_notis(yes : bool):
	for body in npcs_in_range:
		if yes:
			body.notify_near(false)
		else:
			body.notify_near(true)
	for body in objects_in_range:
		if yes:
			body.notify_near(false)
		else:
			body.notify_near(true)
			
func _on_interact_area_body_entered(body):
	if body is StaticNPC3D:
		body.notify_near(true)
		npcs_in_range.append(body)
				
func _on_interact_area_body_exited(body):
	if body is StaticNPC3D:
		body.notify_near(false)
		npcs_in_range.erase(body)
