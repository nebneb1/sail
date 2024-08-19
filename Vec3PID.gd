extends Node
class_name Vec3PID

var kp : float = 0.4
var ki : float = 0.1
var kd : float = 0.0
var ka : float = 0.1

var x_pid = null
var z_pid = null
var y_pid = null

func _init(_kp : float, _ki : float = 0.0, _kd : float = 0.0, _ka : float = 0.0):
	kp = _kp
	ki = _ki
	kd = _kd
	ka = _ka
	x_pid = PID.new(kp, kd, ki, ka)
	y_pid = PID.new(kp, kd, ki, ka)
	z_pid = PID.new(kp, kd, ki, ka)
	
func step(total_error: Vector3, delta : float):
	var total_pid = Vector3()
	total_pid.x = x_pid.step(total_error.x, delta)
	total_pid.y = y_pid.step(total_error.y, delta)
	total_pid.z = z_pid.step(total_error.z, delta)
	return total_pid

func reset():
	x_pid.reset()
	y_pid.reset()
	z_pid.reset()
