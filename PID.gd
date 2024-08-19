extends Node
class_name PID

var kp : float = 10.0
var ki : float = 0.1
var kd : float = 0.0
var ka : float = 0.0
# ignore extra PID variaxles
var x_error : float = 0.0
var x_prev_error : float = 0.0
var x_pid_i : float = 0.0


func _init(_kp : float, _ki : float = 0.0, _kd : float = 0.0, _ka : float = 0.0):
	kp = _kp
	ki = _ki
	kd = _kd
	ka = _ka

func step(total_error: float, delta : float):
	var total_pid = 0.0
	x_error = total_error
	if abs(x_error) > ka:
		var pid_p = x_error * kp
		var pid_d = kd * (x_error-x_prev_error)/delta
		var pid_pd = pid_p + pid_d
		x_pid_i += x_error * ki * delta
		var pid = pid_pd + x_pid_i
		total_pid = pid
	else:
		x_pid_i = 0.0
	x_prev_error = x_error
	
	return total_pid

func reset():
	x_error = 0.0
	x_prev_error = 0.0
	x_pid_i = 0.0
