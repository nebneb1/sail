extends Node3D

@onready var world_env = $WorldEnvironment
enum Weather {
	CLEAR,
	FOGGY
}
const WETHER_CHANGE_PROBABILITY = 10 #1/n check every min


var curr_weather : Weather = Weather.CLEAR
const MAX_FOG_DENSITY = 0.007
const WEATHER_CHANGE_DURR = 120.0
var fog_ammount = 0.0



func _ready():
	randomize()
	world_env.environment.fog_enabled = true
	$WetherTimer.start()

func _on_wether_timer_timeout() -> void:
	$WetherTimer.start()
	if randi_range(1, WETHER_CHANGE_PROBABILITY) == 1:
	#if true:
		match curr_weather:
			Weather.FOGGY:
				var tween := create_tween()
				tween.tween_property(world_env, "environment:fog_density", 0.0, WEATHER_CHANGE_DURR)
		
		while true:
			var random_weather = Weather.values()[randi()%Weather.size()]
			if random_weather != curr_weather:
				curr_weather = random_weather
				break
		
		match curr_weather:
			Weather.FOGGY:
				var tween := create_tween()
				tween.tween_property(world_env, "environment:fog_density", MAX_FOG_DENSITY, WEATHER_CHANGE_DURR)
	
