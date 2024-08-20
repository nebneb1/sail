extends Node

var num_playing = 2
var music : Array = []
var random_pool : Array = []



func _ready():
	#Debug.track(self, "disabled")
	randomize()
	for child in get_children():
		if child is AudioStreamPlayer:
			music.append([child.name, child])
			random_pool.append([child.name, child])
		else:
			for child1 in child.get_children():
				if child1 is AudioStreamPlayer:
					music.append([child1.name, child1])
	get_song("Ocean").play()
	get_song("Ocean").fade_in(15.0)


var timer_started := false
func _process(delta: float):
	if not timer_started and Global.game_started:
		timer_started = true
		$Timer.start()

var disabled = false
func _on_timer_timeout() -> void:
	$Timer.start()
	if randi_range(1,4) == 4 and not disabled: 
		var count = 0
		num_playing = clamp(num_playing + (randi_range(0, 1)*2-1), 1, 4)
		var playing = []
		
		for song in random_pool:
			if song[1].playing == true:
				playing.append(song[0])
				count += 1
		if count < num_playing:
			if get_song("Main").playing == false:
				get_song("Main").play()
				get_song("Main").fade_in(30.0)
			else:
				while true:
					var song = random_pool.pick_random()
					if not ((song[0] == "Theme" or song[0] == "ThemeDistant") and (playing.has("Theme") or playing.has("ThemeDistant"))):
						if song[1].playing == false and (song[0] != "Guitar" or randi_range(0,1) == 1):
							song[1].play()
							break
	

func get_song(song: String):
	for track in music:
		if track[0] == song:
			return track[1]
	return null

func fade_in(song, time := 1.0):
	if get_song(song) != null:
		get_song(song).fade_in(time)
		
		
func fade_out(song, time := 1.0):
	get_song(song).fade_out(time)

func fade_out_all(time := 1.0):
	for song in music:
		if song[0] != "Ocean":
			song[1].fade_out(time)

func fade_in_all(time := 1.0):
	for song in music:
		if song[0] != "Ocean":
			song[1].fade_in(time)
