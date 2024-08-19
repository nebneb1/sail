extends AnimatableBody3D

const SPEED_TILT_AMMOUNT = 2.0
const ROCK_AMMOUNT = 3.0
const THERORETICAL_MAX_SPEED = 10.0 #prev 15  # falls off quickly 6.17
const SPEED_FALLOFF_POWER = 1.0
const IRONS_SPEED_DECRESE_RATE = 0.1
const accel = 0.3 # how fast speed goes to target speed m/s/s
var potential_speed = 0.0 # maximum possible speed at ur heading
var target_speed = 0.0 # your speed based on where u have everything positioned, speed naturally approaches this number
var speed := 0.0

const TILT_ACCEL = 2.0
var target_tilt = 0.0
var tilt :=  0.0

var direction : float = 10.0 # in degrees cos im a masochist
var rot_momentum : float = 0.0
const ROT_DRAG = 0.5

const SAIL_LIMITS = [12.0, 90.0]
const SAIL_LEEWAY = 35.0
var main_sheet_angle : float = SAIL_LIMITS[0]
var main_sheet_target : float
var main_sheet_accel : float = 0.0
var main_sheet_luffing := 0.0

const JIB_LEEWAY = 0.1
const JIB_TIGHTENING_SPEED = 0.2
const JIB_PERFECT_IRONS_BOOST = 1.05
const JIB_RANGES = [0.85, 0.99] # min for boost, max for perfect
var jib_perfect_boost := 1.0
var jib_tightness : Array = [1.0, 0.0]
var jib_target := 0.0
var jib_accel := 5.0
var jib_angle := 0.0
var jib_luffing := 0.0

const TILLER_LIMITS = [-80.0, 80.0]
var tiller_angle := 0.0
var tiller_target := 0.0
var tiller_speed := 45.0
var tiller_accel := 100.0

const DANGER_LIMIT = 5.0
var danger_timer = 0.0



var on_port := false
var prev_on_port := false

var disable_controls := false

@export var main_sheet_ghost : Node3D # Ghost for where the optimal main sheet is
@export var main_sheet : Node3D # the larger sail twards the back
@export var jib : Node3D # the smaller sail thats closer to the front
@export var telltale : Node3D # this is the thing on top that tells the wind direction
@export var tiller : Node3D # this is the rudder at the back that steers
var optimal_angle = 0.0
const GHOST_THRESHOLD = 10.0
const GHOST_TIME = 3.0
const GHOST_ACCEL = 1.0
var ghost_timer = 0.0
var hit_sand = false

func _ready():
	Global.boat = self
	#print(fmod(269.7, 360), " ", fmod(-155, 360), fmod(0, 360))
	#Debug.track(self, "on_port")
	#Debug.track(self, "main_sheet_target")
	#Debug.track(self, "jib_tightness")
	#Debug.track(self, "tiller_angle")
	#Debug.track(self, "tiller_target")
	#Debug.track(self, "speed")
	#Debug.track(self, "direction")
	#Debug.track(self, "target_speed")
	#Debug.track(self, "potential_speed")
	#Debug.track(self, "optimal_angle")
	
	
var time = 0.0
var pull_mainsheet_in : bool = false
var pull_mainsheet_out : bool = false
var pull_starboard_jib_in : bool = false
var pull_starboard_jib_out : bool = false
var pull_port_jib_in : bool = false
var pull_port_jib_out : bool = false
var tiller_left : bool = false
var tiller_right : bool = false
@export var anchor_down : bool = true

func _physics_process(delta: float):
	time += delta
	disable_controls = false
	if on_port:
		if pull_mainsheet_in and not disable_controls:
			main_sheet_accel = 10.0
			main_sheet_target = clamp(main_sheet_target - main_sheet_accel * delta, SAIL_LIMITS[0], SAIL_LIMITS[1])
			
			
		elif pull_mainsheet_out and not disable_controls:
			main_sheet_accel = 100.0
			main_sheet_target = clamp(main_sheet_target + main_sheet_accel * delta, SAIL_LIMITS[0], SAIL_LIMITS[1])
			main_sheet_accel = 10.0
	else:
		if pull_mainsheet_in and not disable_controls:
			main_sheet_accel = 10.0
			main_sheet_target = clamp(main_sheet_target - main_sheet_accel * delta * -1, -SAIL_LIMITS[1], -SAIL_LIMITS[0])
			
			
			
		elif pull_mainsheet_out and not disable_controls:
			main_sheet_accel = 100.0
			main_sheet_target = clamp(main_sheet_target + main_sheet_accel * delta * -1, -SAIL_LIMITS[1], -SAIL_LIMITS[0])
			main_sheet_accel = 10.0
		
	if pull_port_jib_in and not disable_controls:
		tighten_jib(true, JIB_TIGHTENING_SPEED * delta)
	
	if pull_starboard_jib_in and not disable_controls:
		tighten_jib(false, JIB_TIGHTENING_SPEED * delta)
	
	if pull_port_jib_out and not disable_controls:
		tighten_jib(true, -JIB_TIGHTENING_SPEED * delta * 2.0)
	
	if pull_port_jib_out and not disable_controls:
		tighten_jib(false, -JIB_TIGHTENING_SPEED * delta * 2.0)
	
		
	
	# when heading upwind, you are "in irons," while in irons, you slow down quickly and lose the ability to turn if you are slowed all the way down 
	# You want the jib barely untightened but mostly tightened all the way to the side ur sailing on
	jib_perfect_boost = 1.0
	if is_angle_between(direction, Global.wind_thresholds[0][0], Global.wind_thresholds[0][1] * jib_perfect_boost) or is_angle_between(direction, Global.wind_thresholds[1][0], Global.wind_thresholds[1][1] * jib_perfect_boost):
		# Sailing calculations
		potential_speed = (pow(clamp((calculate_difference(direction, Global.wind_direction) / 180.0)*0.5+0.5, 0.0, 1.0), SPEED_FALLOFF_POWER))
		var drawback_multiplier = 0.0
		
		
		# Jib bonuses
		#print(direction, " ", Global.wind_thresholds[0][0], " ", Global.wind_thresholds[0][1] * jib_perfect_boost)
		#print(is_angle_between(direction, Global.wind_thresholds[0][0], Global.wind_thresholds[0][1] * jib_perfect_boost))
		if is_angle_between(direction, Global.wind_thresholds[0][0], Global.wind_thresholds[0][1] * jib_perfect_boost):
			on_port = true
			if jib_tightness[0] >= JIB_RANGES[0]:
				drawback_multiplier += 0.25
				if jib_tightness[0] <= JIB_RANGES[1]:
					drawback_multiplier += 0.05
					jib_perfect_boost = JIB_PERFECT_IRONS_BOOST
					jib_luffing = 0.0
				else:
					jib_luffing = 2.0
			else:
				jib_luffing = 10.0
		else:
			on_port = false
			if jib_tightness[1] >= JIB_RANGES[0]:
				drawback_multiplier += 0.25
				if jib_tightness[1] <= JIB_RANGES[1]:
					drawback_multiplier += 0.05
					jib_perfect_boost = JIB_PERFECT_IRONS_BOOST
					jib_luffing = 0.0
				else:
					jib_luffing = 2.0
			else:
				jib_luffing = 10.0
		
		# Main sheet bounuses
		optimal_angle = (1 - calculate_difference(direction, Global.wind_direction)/180.0) * SAIL_LIMITS[1] * (float(on_port)*2-1)
		if abs(main_sheet_angle - optimal_angle) < SAIL_LEEWAY:
			main_sheet_luffing = 0.0
			drawback_multiplier += ((SAIL_LEEWAY - abs(main_sheet_angle - optimal_angle)) / SAIL_LEEWAY) * 0.6
		
		# Tiller bonus
		drawback_multiplier += (1.0 - abs(tiller_angle)/80.0) * 0.1
		
		# calc final speed
		target_speed = drawback_multiplier * potential_speed * THERORETICAL_MAX_SPEED
		
		
		
	elif is_angle_between(direction, Global.wind_thresholds[2][0], Global.wind_thresholds[2][1]):
		if target_speed > 5: target_speed = 5.0
		target_speed = clamp(target_speed + delta * IRONS_SPEED_DECRESE_RATE, 0.1, 100.0)
		main_sheet_luffing = 10.0
		jib_luffing = 10.0
		
	elif is_angle_between(direction, Global.wind_thresholds[3][0], Global.wind_thresholds[3][1]):
		# in danger zone
		danger_timer += delta
		if danger_timer > DANGER_LIMIT:
			danger_crash(on_port)
			danger_timer = 0.0
			
	
	elif danger_timer > 0:
		danger_timer = clamp(danger_timer - delta, 0.0, DANGER_LIMIT)
		
	
	telltale.global_rotation_degrees.y = Global.wind_direction + 180
	
	main_sheet_angle += (main_sheet_target - main_sheet_angle) * main_sheet_accel * delta
	main_sheet.rotation_degrees.y = main_sheet_angle
	
	jib_target = (jib_tightness[0] - jib_tightness[1]) * SAIL_LIMITS[1]/2.0
	jib_angle += (jib_target - jib_angle) * jib_accel * delta
	jib.rotation_degrees.y = jib_angle
	if anchor_down or hit_sand: 
		if Global.game_started != true:
			Global.game_started = true
		target_speed = 0.0
		if hit_sand and not anchor_down:
			target_speed = -1.0
			rot_momentum = -1.0
	
	if target_speed > 2.5 and not $IslandCollider.get_overlapping_areas().has(Global.player.get_node("Area3D")):
		target_speed = 2.5
	
	speed += (target_speed - speed) * accel * delta * (float(anchor_down or hit_sand)*2+1)
	# speed = clamp(speed, 0.0, max_speed)1.261
	global_position += Global.convert_vec(Vector2(-cos(deg_to_rad(direction)), sin(deg_to_rad(direction)))) * speed * delta
	global_position.y = Global.GROUND_LEVEL
	
	if tiller_left and not disable_controls:
		tiller_target = clamp(tiller_target + delta * tiller_speed, TILLER_LIMITS[0], TILLER_LIMITS[1])
		
	elif tiller_right and not disable_controls:
		tiller_target = clamp(tiller_target - delta * tiller_speed, TILLER_LIMITS[0], TILLER_LIMITS[1])
	
	elif abs(tiller_target) < 1.0:
		tiller_target = 0
	
	else:
		tiller_target -= tiller_target * delta * speed
	
	if Global.help_mode and abs(main_sheet_angle - optimal_angle) > GHOST_THRESHOLD:
		main_sheet_ghost.show()
		main_sheet_ghost.rotation_degrees.y += (optimal_angle - main_sheet_ghost.rotation_degrees.y) * GHOST_ACCEL * delta
		ghost_timer += delta
		if ghost_timer >= GHOST_TIME:
			ghost_timer = 0
			main_sheet_ghost.rotation_degrees.y = main_sheet_angle
	
	else:
		main_sheet_ghost.hide()
		
	tiller_angle += (tiller_target - tiller_angle) * tiller_accel * delta
		
	rot_momentum -= rot_momentum * ROT_DRAG * delta
	if abs(rot_momentum) < 1.0:
		rot_momentum = 0
	
	
	
	tiller.rotation_degrees.y = tiller_angle
	
	
	
	if abs(tiller_angle) != 0.0:
		rot_momentum = -tiller_angle * speed / 10.0
	
	
	direction += rot_momentum * delta
	rotation_degrees.y = direction
	target_tilt = sin(time) * ROCK_AMMOUNT + speed * -(int(on_port)*2-1) * SPEED_TILT_AMMOUNT
	tilt += (target_tilt - tilt) * TILT_ACCEL * delta
	rotation_degrees.x = tilt
	
	
	
	if prev_on_port != on_port:
		main_sheet_accel = 3.0
		main_sheet_target *= -1
	prev_on_port = on_port 
	

func tighten_jib(port : bool, ammount : float):
	if port:
		if jib_tightness[0] + ammount > 1.0 - jib_tightness[1]: pass # do some anim or smtn
		jib_tightness[0] = clamp(jib_tightness[0] + ammount, 0.0, 1.0 - jib_tightness[1])
		
	else:
		if jib_tightness[1] + ammount > 1.0 - jib_tightness[0]: pass # do some anim or smtn
		jib_tightness[1] = clamp(jib_tightness[1] + ammount, 0.0, 1.0 - jib_tightness[0])

func danger_crash(port: bool):
	pass
	#if port: $BoomSwing.play("boom_swing_port")
	#else: $BoomSwing.play("boom_swing_starboard")

func is_angle_between(target : float, angle1 : float, angle2: float): # thanks stack exchange !
	target = fmod(target, 360.0)
	angle1 = fmod(angle1, 360.0)
	angle2 = fmod(angle2, 360.0)
	while target < 0: target += 360
	while angle1 < 0: angle1 += 360
	while angle2 < 0: angle2 += 360
	var rAngle = fmod((fmod((angle2 - angle1), 360) + 360), 360)
	if rAngle >= 180:
		var temp = angle1
		angle1 = angle2
		angle2 = temp

	if angle1 <= angle2:
		return target >= angle1 and target <= angle2
	
	return target >= angle1 or target <= angle2


func calculate_difference(angle1 : float, angle2 : float): # thanks gdforms !
	var angle = abs(fmod(angle1, 360) - fmod(angle2, 360))
	if angle > 180.0:
		return 360.0 - angle
	return angle

const COLLISION_SPEED_LOSS = 0.8
const COLLISION_ROT_MOME_RANGE = 10.0
func _on_island_collider_area_entered(area: Area3D) -> void:
	if area.is_in_group("hard_collider"):
		speed = -speed * COLLISION_SPEED_LOSS
		anchor_down = false
		rot_momentum = randf_range(COLLISION_ROT_MOME_RANGE, -COLLISION_ROT_MOME_RANGE)
	elif area.is_in_group("soft_collider"):
		anchor_down = true
		hit_sand = true


func _on_island_collider_area_exited(area: Area3D) -> void:
	if area.is_in_group("soft_collider"):
		$sand_time.start()


func _on_sand_time_timeout() -> void:
	hit_sand = false
