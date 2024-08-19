extends Node3D

@onready var world_env = $WorldEnvironment
enum Weather {
	CLEAR,
	FOGGY,
	RAINY
}
const WETHER_CHANGE_PROBABILITY = 15 #1/n check every min


var curr_weather : Weather = Weather.CLEAR
const MAX_FOG_DENSITY = 0.01
const WEATHER_CHANGE_DURR = 60.0
var fog_ammount = 0.0

var prev_scale_map = Global.scale_map
func _process(delta: float):
	if prev_scale_map != Global.scale_map:
		if Global.scale_map:
			if curr_weather != Weather.RAINY:
				disable_weather(1.0)
		else:
			if curr_weather != Weather.RAINY:
				enable_weather(1.0)
	
	prev_scale_map = Global.scale_map
	

func disable_weather(speed : float):
	match curr_weather:
		Weather.FOGGY:
			var tween := create_tween()
			tween.tween_property(world_env, "environment:fog_density", 0.0, speed)
		
		Weather.RAINY:
			var tween := create_tween()
			tween.tween_property(world_env, "environment:fog_density", 0.0, speed)
			disable_rain()
			#tween.connect("finished", Callable(self, "disable_rain"))

func enable_weather(speed : float):
	match curr_weather:
		Weather.FOGGY:
			var tween := create_tween()
			tween.tween_property(world_env, "environment:fog_density", MAX_FOG_DENSITY, speed)
			
		Weather.RAINY:
			var tween := create_tween()
			tween.tween_property(world_env, "environment:fog_density", MAX_FOG_DENSITY*2.0, speed)
			tween.connect("finished", Callable(self, "enable_rain"))
			

func enable_rain():
	Music.fade_out_all(10.0)
	randomize()
	if randi_range(0,1) == 1:
		Music.get_song("Rain1").play()
		Music.fade_in("Rain1", 10.0)
	else:
		Music.get_song("Rain2").play()
		Music.fade_in("Rain2", 10.0)
	#Music.fade_in("Ocean", 0.001)
	Music.disabled = true
	$CPUParticles3D.emitting = true

func disable_rain():
	$CPUParticles3D.emitting = false


func _ready():
	randomize()
	Global.game = self
	world_env.environment.fog_enabled = true
	$WetherTimer.start()
	curr_weather = Weather.RAINY
	enable_weather(WEATHER_CHANGE_DURR)

func _on_wether_timer_timeout() -> void:
	$WetherTimer.start()
	if randi_range(1, WETHER_CHANGE_PROBABILITY) == 1:
	#if true:
		disable_weather(WEATHER_CHANGE_DURR)
		
		while true:
			var random_weather = Weather.values()[randi()%Weather.size()]
			if random_weather != curr_weather:
				curr_weather = random_weather
				
				break
		
		enable_weather(WEATHER_CHANGE_DURR)
	
