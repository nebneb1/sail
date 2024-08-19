extends AudioStreamPlayer

@export var vol_modifier = 1.0
var on = true 
var timer = 1.0
var delta_timer = 0.0
var vol := 1.0

var targ := 0.0
var manual_vol_overide := false

func _process(delta):
	if not manual_vol_overide:
		if on: targ =  1.0
		else: targ = 0.0
	
	if vol <= targ:
		vol += delta/timer
		
	if vol >= targ:
		vol -= delta/timer
	
#	if (db_to_linear(volume_db) <= targ and not on) or (db_to_linear(volume_db) >= targ and on):
#		timer = 1.0
	
	#this needs to be removed, causes known bug
#	vol = clamp(vol*vol_modifier, 0.0, 2.0)
	if name == "void":
		pass
#		print(vol, " ", vol_modifier, " ", volume_db)
	volume_db = linear_to_db(clamp(vol*vol_modifier, 0.0, 2.0))
	

func fade_out(time := 1.0):
	timer = time
	manual_vol_overide = false
	on = false

func fade_in(time := 1.0):
	vol = 0.0
	timer = time
	manual_vol_overide = false
	on = true
