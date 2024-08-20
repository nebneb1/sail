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
const WEATHER_CHANGE_DURR = 120.0
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
	if Global.save_file_exists():
		Global.loadd()
	
	Global.dialog = self
	world_env.environment.fog_enabled = true
	$WetherTimer.start()
	#curr_weather = Weather.RAINY
	#enable_weather(WEATHER_CHANGE_DURR)

	speakers["c"] = $CompassNPC.dialog_entity
	#$CompassNPC.base_convos = [['compass-1', 'compass-2']]
	init_dialog("res://Dialog/script.txt", Global.export)

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

# DIALOG STUFF
var input_to_continue : bool = false
var speakers = {
	"default" : null,
	
}
var convos = {}

func parse_glob(glob_path : String):
	var f = FileAccess.open(glob_path, FileAccess.READ)
	# var index = 0 # POTENTIAL CAUSE OF ERROR WATCH OUT
	var cur_parsing_convo_name = ""
	var cur_parsing_snippet_name = ""
	var cur_choices : Array = []
	while not f.eof_reached():
		# index += 1 # iterate through all lines until the end of file is reached
		var line = f.get_line()
		line = line.strip_edges()
		if len(line) == 0 or line[0] == "#": # COMMENT OR EMPTY LINE
			continue
		#print(line)
		if line[0] == ">":
			if cur_choices != []:
				convos[cur_parsing_convo_name]["snippets"][cur_parsing_snippet_name].append(cur_choices)
				cur_choices = []
			var cp = line.substr(1).split(">")
			var convo_name = cp[0].strip_edges()
			var lock_player = cp[1].strip_edges()
			if lock_player == "F":
				lock_player = false
			else:
				lock_player = true
			convos[convo_name] = {
				"participants" : [],
				"lock_player" : lock_player,
				"interrupt" : true,
				"snippets" : {}
			}
			cur_parsing_convo_name = convo_name
		elif line[0] == "|":
			if cur_choices != []:
				convos[cur_parsing_convo_name]["snippets"][cur_parsing_snippet_name].append(cur_choices)
				cur_choices = []
			var snippet_name = line.substr(1).strip_edges()
			cur_parsing_snippet_name = snippet_name
			convos[cur_parsing_convo_name]["snippets"][cur_parsing_snippet_name] = []
		elif line[0] == "^":
			if cur_parsing_snippet_name != "":
				cur_choices = ["choice"]
		else:
			if cur_parsing_snippet_name != "":
				var cp = line.split("|")
				if cur_choices != []:
					var next_convo_name = cp[0].strip_edges()
					var text = cp[1].strip_edges()
					cur_choices.append([next_convo_name, text])
					if !convos[cur_parsing_convo_name]["participants"].has("player"):
						convos[cur_parsing_convo_name]["participants"].append("player")
				else:
					var speaker = cp[0].strip_edges()
					var attr = parse_line_by_char(cp[1], ",")
					var text = cp[2].strip_edges()
					if len(cp) > 3:
						var cont = float(cp[3].strip_edges())
						convos[cur_parsing_convo_name]["snippets"][cur_parsing_snippet_name].append([speaker, attr, text, cont])
					else:
						convos[cur_parsing_convo_name]["snippets"][cur_parsing_snippet_name].append([speaker, attr, text])
					if !convos[cur_parsing_convo_name]["participants"].has(speaker):
						convos[cur_parsing_convo_name]["participants"].append(speaker)
	if cur_choices != []:
		convos[cur_parsing_convo_name]["snippets"][cur_parsing_snippet_name].append(cur_choices)
		cur_choices = []
	f.close()
	var export_glob_path = glob_path.split(".")[0] + "_export.json"
	var json_string = JSON.stringify(convos)
	var f2 = FileAccess.open(export_glob_path, FileAccess.WRITE)
	f2.store_string(json_string)
	f2.close()

func parse_line_by_char(line : String, char : String):
	var l = line.strip_edges().split(char)
	var la : Array = []
	for a in l:
		a = a.strip_edges()
		la.append(a)
	return la
	
func init_dialog(dialog_path : String, is_export : bool):
	if is_export:
		var export_glob_path = dialog_path.split(".")[0] + "_export.json"
		var f = FileAccess.open(export_glob_path, FileAccess.READ)
		var json = JSON.new()
		convos = json.parse_string(f.get_as_text())
		f.close()
	else:
		parse_glob(dialog_path)
	
func assign_speaker(_name : String, _object):
	speakers[name] = _object.dialog_entity

func start_convo(convo_name : String):
	if convos[convo_name] == null:
		return
		
	var new_convo = convos[convo_name]

	if new_convo["interrupt"]:
		for participant in new_convo["participants"]:
			if speakers[participant].in_convo():
				speakers[participant].leave_convo(true)
		# end current convos in participants because convo is interrupt mandatory
	else:
		var can_continue = true
		for participant in new_convo["participants"]:
			if speakers[participant].in_convo():
				can_continue = false
		if !can_continue:
			return
	# continue here
	for participant in new_convo["participants"]:
		speakers[participant].cur_convo_name = convo_name
	if new_convo["lock_player"]:
		$Player.disable = true
	var start_snippet_name = "init"
	var start_convo_pos = 0
	var start_speaker = speakers[convos[convo_name]["snippets"][start_snippet_name][0][0]]
	start_speaker.join_convo(convo_name, start_snippet_name, start_convo_pos)
		
func end_convo(convo_name : String):
	# This is when a certain convo has finished and needs terminating in the participants
	# Will be triggered by the speaker with the last line in the convo that was started
	if convos[convo_name] == null:
		return
		
	var new_convo = convos[convo_name]
	if new_convo["lock_player"]:
		$Player.disable = false
	for participant in new_convo["participants"]:
		speakers[participant].leave_convo()
