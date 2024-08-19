extends Node

var wind_direction : float = 0
var wind_speed : float = 10.0 # 10 is standard
const GROUND_LEVEL = 1.261
var game_started = true
@onready var player : RigidBody3D
@onready var boat : Node3D


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


var ground_level : float = 0.0

func convert_vec(vec : Vector2):
	return Vector3(vec.x, ground_level, vec.y)

func update_thresholds():
	for i in range(4):
		for k in range(2):
			wind_thresholds[i][k] = RELITIVE_THRESHOLDS[i][k] + wind_direction
	

func _process(delta: float):
	update_thresholds()
