extends Node3D

@export var target : Node3D
@onready var camera = $Camera3D
@export var sea : Node2D
@export var sea2 : Node2D
@export var zoom_in_pos : Node3D
@export var zoom_out_pos : Node3D
var velocity : Vector2 = Vector2.ZERO
var movement_enabled = true

const DRAG = 10.0
const SENSITIVITY = Vector2(1.0, 1.0)

const ZOOM_STEP = 1.2
const ZOOM_SPEED = 2.0
const MIN_ZOOM = 45.0
const MAX_ZOOM = 300000.0
var zoom_target = 60.0
var zoom = 60.0

const TOP_VIEW_THRESHOLD = 150.0
const ZOOM_CONSTANT = 130.0
const MOVE_SPEED = 1.0

var cam_target_pos : Vector3
var cam_target_rotation : Vector2

func _ready():
	enable()

func disable():
	movement_enabled = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func enable():
	movement_enabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

const LERP = 1.0

func _process(delta: float):
	rotation.y += velocity.x*delta*SENSITIVITY.x
	if velocity.x > 0: velocity.x -= velocity.x*DRAG*delta
	elif velocity.x < 0: velocity.x -= velocity.x*DRAG*delta
	if target: global_position = lerp(global_position, target.global_position, delta * LERP)
	
	if abs(zoom_target - zoom) > 0.001:
		zoom += (zoom_target - zoom) * ZOOM_SPEED * delta
	
	camera.size = zoom
	sea.scale = Vector2(ZOOM_CONSTANT/zoom, ZOOM_CONSTANT/zoom)
	sea2.scale = Vector2(ZOOM_CONSTANT/zoom, ZOOM_CONSTANT/zoom)
	
	if zoom > TOP_VIEW_THRESHOLD:
		cam_target_pos = zoom_out_pos.position
		cam_target_rotation = Vector2(-zoom_out_pos.rotation.x, zoom_out_pos.rotation.z)
		Global.scale_map = true
	else:
		cam_target_pos = zoom_in_pos.position
		cam_target_rotation = Vector2(zoom_in_pos.rotation.x, zoom_in_pos.rotation.z)
		Global.scale_map = false
	
	camera.position += (cam_target_pos - camera.position) * MOVE_SPEED * delta
	camera.rotation += (Vector3(cam_target_rotation.x, camera.rotation.y, cam_target_rotation.y) - camera.rotation) * MOVE_SPEED * delta
	#if Global.mini_player:
		#global_rotation_degrees.y = 90.0
		#zoom_target = MIN_ZOOM


func _input(event: InputEvent):
	if event is InputEventMouseMotion and movement_enabled:
		velocity.x += -deg_to_rad(event.relative.x)
	
	elif event.is_action_pressed("escape"):
		if movement_enabled:
			disable()
		else:
			enable()
	
	if event.is_action_pressed("camera_zoom_in"):
		zoom_target = clamp(zoom_target / ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
	
	elif event.is_action_pressed("camera_zoom_out"):
		zoom_target = clamp(zoom_target * ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
