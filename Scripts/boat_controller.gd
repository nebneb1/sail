extends Node3D

@export var body : Node3D
@export var main_sheet : Node3D
@export var jib : Node3D # the smaller sail thats closer to the front
@export var telltale : Node3D # this is the thing on top that tells the wind direction
@export var tiller : Node3D # this is the rudder at the back that steers

@export var max_speed : float = 6.17 # approx max speed for a sloop

var speed := 0.0

func _process(delta: float):
	pass
