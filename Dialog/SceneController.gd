extends Node

class_name Episode

var scenes_in_game : Dictionary = {
	"menu" : preload("res://Scenes/menu.tscn"),
	"game" : preload("res://Scenes/main.tscn")
}
var cur_scene_name = 3
var cur_scene = null
var effect_out = "none"

@onready var screen_fade : ColorRect = $CanvasLayer2/ColorRect
@onready var screen_pinhole : ColorRect = $CanvasLayer/ColorRect
var tween: Tween
var temp_out_time : float = 0.1
var transitioning : bool = false
var trans_type = "pinhole"

func _ready():
	$CanvasLayer2/ColorRect.color = "000000"
	add_to_group('controller')
	call_deferred("switch_scene", "menu", 0.0, 2.0, "pinhole")
	Global.scene_controller = self
	
var ff := 0.0
func switch_scene(new_scene_name, in_time : float = 0.0, out_time : float = 0.0, _trans_type="none", full_fade_out : bool = false):
	if !transitioning and scenes_in_game.keys().has(new_scene_name):
		if full_fade_out:
			ff = out_time
			Music.full_fade_out(in_time/10)
		else: ff = 0.0
#		effect_out = sound_effect_out
#		match sound_effect_in:
#			"odd": $SFX/odd.play(0.75)
#			"deep": $SFX/deep.play(5.85)
#			"book": $SFX/book.play()
#			"relax": $SFX/relax.play(193)
		
		
		cur_scene_name = new_scene_name
		temp_out_time = out_time
		transitioning = true
		trans_type = _trans_type
		if trans_type == "pinhole":
			tween = create_tween()
			tween.connect("finished",Callable(self,"tween_finished"))
			tween.tween_property(screen_pinhole.get_material(), "shader_parameter/circle_size", -0.2, in_time).from_current()
		elif trans_type == "fade":
			tween = create_tween()
			tween.connect("finished",Callable(self,"tween_finished"))
			tween.tween_property(screen_fade, "color:a", 1.0, in_time).from_current()
		elif trans_type == "none":
			screen_fade.color = Color(0.0, 0.0, 0.0, 1.0)
			fade_out()
	else:
		pass
#		print("Cur scene name does not exist or in transition")


func fade_out():
#	match effect_out:
#		"odd": $SFX/odd.play(0.75)
#		"deep": $SFX/deep.play(5.85)
#		"book": $SFX/book.play()
#		"relax": $SFX/relax.play(193)
#
#	effect_out = "none"
	if ff != 0.0:
		Music.full_fade_in(ff/10)
	if cur_scene != null:
		cur_scene.free()
	cur_scene = scenes_in_game[cur_scene_name].instantiate()
	add_child(cur_scene)
	if trans_type == "pinhole":
		tween = create_tween()
		tween.connect("finished",Callable(self,"tween_finished"))
		tween.tween_property(screen_pinhole.get_material(), "shader_parameter/circle_size", 1.2, temp_out_time).from_current()
	elif trans_type == "fade":
		tween = create_tween()
		tween.connect("finished",Callable(self,"tween_finished"))
		tween.tween_property(screen_fade, "color:a", 0.0, temp_out_time).from_current()
	elif trans_type == "none":
		screen_fade.color = Color(0.0, 0.0, 0.0, 0.0)
		transitioning = false
	temp_out_time = -1.0

func tween_finished():
	if temp_out_time == -1.0:
		transitioning = false
	else:
		$Timer.start(1.5)

func _on_timer_timeout():
	fade_out()
