extends Node

var wind_direction : float = 0
var wind_speed : float = 10.0 # 10 is standard
const GROUND_LEVEL = 1.261
var game_started = false
@onready var player : CharacterBody3D
@onready var boat : Node3D

var islands_visited = ["starter"]

var saved = false

var game : Node3D
var help_mode = true
var scale_map = false

var wind_thresholds : Array = [ # in radians
	[0.0, 0.0], # sailable port
	[0.0, 0.0], # sailable starboard
	[0.0, 0.0], # irons
	[0.0, 0.0] # danger
]

const DANGER_ZONE_SIZE = 0.0
const IRONS_ANGLE = 155
const RELITIVE_THRESHOLDS : Array = [ # in degrees
	[DANGER_ZONE_SIZE, IRONS_ANGLE], # sailable port
	[-DANGER_ZONE_SIZE, -IRONS_ANGLE], # sailable starboard
	[IRONS_ANGLE, -IRONS_ANGLE], # irons
	[DANGER_ZONE_SIZE, -DANGER_ZONE_SIZE] # danger
]
var mini_player = false
var screen_resolution = Vector2(DisplayServer.window_get_size())
const MINI_PLAYER_SIZE = [160, 90]

var ground_level : float = 0.0

var wind_timer = 0.0
var wind_switch = 0.0
const WIND_SWITCH_RANGE = [3600.0, 10800.0]
const WIND_SWITCH_RATE = [300.0, 600.0]
const WINDOW_SPEED = 50.0

var scene_controller = null
var dialog = null
var export = false
func convert_vec(vec : Vector2):
	return Vector3(vec.x, ground_level, vec.y)

func update_thresholds():
	for i in range(4):
		for k in range(2):
			wind_thresholds[i][k] = RELITIVE_THRESHOLDS[i][k] + wind_direction
	
func _ready() -> void:
	randomize()
	wind_switch = randf_range(WIND_SWITCH_RANGE[0], WIND_SWITCH_RANGE[1])
	

func save():
	print("game saved")
	game.get_node("Save/AnimationPlayer").play("save")
	
	
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	file.store_var([boat.global_position, boat.direction, wind_direction, islands_visited])
	file.close()
	

func save_file_exists() -> bool:
	return FileAccess.file_exists("user://save_game.dat")
	

func loadd():
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	var contents = file.get_var()
	file.close()
	
	game.get_node("Save/AnimationPlayer").play("save")
	print(contents)
	
	saved = true
	boat.anchor_down = true
	boat.global_position = contents[0]
	boat.direction = contents[1]
	wind_direction = contents[2]
	islands_visited = contents[3]
	
	player.global_position = boat.get_node("PlayerSpawn").global_position
	
	

func _process(delta: float):
	update_thresholds()
	#if Input.is_action_pressed("jib_port_in") and not mini_player:
		#mini_player = true
	#if mini_player:
		#get_window().size = Vector2i(MINI_PLAYER_SIZE[0], MINI_PLAYER_SIZE[1])
		#get_window().position += Vector2i(cos(deg_to_rad(boat.direction)) * boat.speed * delta * WINDOW_SPEED, sin(deg_to_rad(boat.direction)) * boat.speed * delta * 10.0 * WINDOW_SPEED)
	#else:
		#get_window().size = screen_resolution
		#screen_resolution = Vector2(DisplayServer.window_get_size())
	
	wind_timer += delta
	if wind_timer > wind_switch:
		wind_switch = randf_range(WIND_SWITCH_RANGE[0], WIND_SWITCH_RANGE[1])
		wind_timer = 0.0
		var tween := create_tween()
		tween.tween_property(self, "wind_direction", randi_range(0.0, 360.0), randf_range(WIND_SWITCH_RATE[0], WIND_SWITCH_RATE[1]))
		
		
	
