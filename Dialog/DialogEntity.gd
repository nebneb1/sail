extends Node
class_name DialogEntity

@export_node_path var dialog_path : NodePath
@export var lowpass : bool = true
@export var quiet : bool = true

var bubble = null
var t
var c

var step_timer = Timer.new()
var end_timer = Timer.new()
var cur_step_per : int = 0

var cur_convo_name : String = ""
var cur_snippet_name : String = ""
var cur_snippet : Array = []
var cur_snippet_pos : int = 0
var cur_line : Array = []
#var cur_choice : int = 0
#var choice_y_tex = Global.preloads["choice"]
#var choice_n_tex = Global.preloads["choice_none"]

var just_conversed : bool = false
var delay_timer : Timer = Timer.new()
var interact_locked : bool = false

signal convo_finished(speaker, convo_name)
signal convo_started(speaker, convo_name)
signal path_switched(convo_name, path_name)
signal convo_delay_finished()
signal text_step()
signal attr_this_line(attrs)

# OPTIONS
var multiline = true
const STEP_SPEED = 0.02
var step_per_letters : int = 2

var tween : Tween

func _ready():
	#bubble = get_node(dialog_path)
	#t = bubble.get_node("Text")
	#c = bubble.get_node("ChoicesContainer")
	add_child(step_timer)
	add_child(end_timer)
	add_child(delay_timer)
	step_timer.connect('timeout', Callable(self, '_on_step_timer_timeout'))
	delay_timer.connect('timeout', Callable(self, '_on_delay_timer_timeout'))
	delay_timer.one_shot = true
	step_timer.one_shot = true
	end_timer.one_shot = true
	end_timer.connect('timeout', Callable(self, '_on_end_timer_timeout'))
	if is_instance_valid(c):
		c.visible = false
	t.visible_characters = -1
	t.text = ""
	#call_deferred("set_accessibility")
	bubble.hide()

func _init(text_c, choice_c, dialog_n):
	t = text_c
	c = choice_c
	bubble = dialog_n
		
func join_convo(new_convo_name : String, new_snippet_name : String, new_snippet_pos : int = 0):
	if new_snippet_pos == 0:
		emit_signal('convo_started', self, new_convo_name)
	cur_convo_name = new_convo_name
	cur_snippet_name = new_snippet_name
	cur_snippet = Global.dialog.convos[cur_convo_name]["snippets"][new_snippet_name]
	cur_snippet_pos = new_snippet_pos
	cur_line = cur_snippet[cur_snippet_pos]
	#if cur_line[0] == "choice":
		#roll_choice()
	#else:
	emit_signal('attr_this_line', cur_line[1])
	roll_text(cur_line[2])
			
func leave_convo(immediate : bool = false):
	emit_signal('convo_finished', self, cur_convo_name)
	cur_convo_name = ""
	cur_snippet_name = ""
	cur_snippet = []
	cur_snippet_pos = 0
	cur_line = []
	if !immediate:
		just_conversed = true
		delay_timer.start(0.5)
	else:
		emit_signal('convo_delay_finished')
		
func is_interact_locked():
	if in_convo() or interact_locked:
		return true
	return false
	
func in_convo() -> bool:
	if cur_convo_name != "" or just_conversed:
		return true
	return false

#func roll_choice():
	#var choices = []
	#choices = cur_line.duplicate(true)
	#choices.remove_at(0)
	#cur_choice = 0 # getting the index of the choice
	#roll_text(choices[cur_choice][1]) # getting the text to roll, not the name of the choice
	#Global.player.set_deferred("choice_input_need", true)
	#c.visible = true
	#var ch_c = 0
	#for child in c.get_children():
		#if ch_c < len(choices):
			#child.visible = true
			#if ch_c == cur_choice:
				#child.texture = choice_y_tex
			#else:
				#child.texture = choice_n_tex
		#else:
			#child.visible = false
		#ch_c += 1
		
#func change_choice(right : bool):
	#t.visible_characters = 0
	#t.text = ""
	#bubble.get_node("ChoiceLeftArrow").hide()
	#bubble.get_node("ChoiceRightArrow").hide()
	#bubble.get_node('AnimationPlayer').stop()
	#var choices = []
	#choices = cur_line.duplicate(true)
	#choices.remove_at(0)
	#
	#if right:
		#cur_choice += 1
	#else:
		#if cur_choice == 0:
			#cur_choice = len(choices) - 1
		#else:
			#cur_choice -= 1 
		#
	#cur_choice = cur_choice % len(choices)
	#roll_text(choices[cur_choice][1])
	#var ch_c = 0
	#for child in c.get_children():
		#if child.visible:
			#if ch_c == cur_choice:
				#child.texture = choice_y_tex
			#else:
				#child.texture = choice_n_tex
		#ch_c += 1
	
func roll_text(new_text : String):
	bubble.z_index = 12
	t.clear()
	t.size = Vector2()
	t.autowrap_mode = TextServer.AUTOWRAP_OFF
	if multiline:
		#t.size = t.get('theme_override_fonts/font').get_string_size(new_text)
#		print(t.size)
		t.size = t.get('theme_override_fonts/normal_font').get_string_size(new_text)
#		print(t.size)
		if t.size.x > 300:
			t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			t.size.x = 320
		else:
			t.size = Vector2()
			t.autowrap_mode = TextServer.AUTOWRAP_OFF
	t.visible_characters = 0
	#t.text = new_text
	t.append_text("[center]" + new_text)
	t.position = -Vector2(t.size.x / 2, t.size.y)
	#c.position = -Vector2(t.size.x / 2, t.size.y)
	step_timer.start(STEP_SPEED)
	bubble.show()
	bubble.scale = Vector2(0.6, 0.6)
	bubble.position = Vector2(480, 270)
	tween = create_tween()
	if is_instance_valid(tween):
		#tween.connect("finished",Callable(self,"tween_finished"))
		tween.tween_property(bubble, 
		"scale", 
		Vector2(1.0, 1.0), 0.1).from(Vector2(0.2, 0.2)).set_ease(Tween.EASE_IN)
		tween.tween_property(bubble, 
		"position", 
		bubble.position + Vector2(0, -20), 0.1).from_current().set_ease(Tween.EASE_IN).set_delay(0.0)
	
func next_dialog():
	bubble.hide()
	bubble.get_node("ChoiceLeftArrow").hide()
	bubble.get_node("ChoiceRightArrow").hide()
	bubble.get_node('AnimationPlayer').stop()
	t.visible_characters = 0
	t.text = ""
	#if cur_line[0] == "choice": # SWITCH TO NEXT SNIPPET
		#var next_snippet_name = cur_line[cur_choice + 1][0]
		#emit_signal('path_switched', cur_convo_name, next_snippet_name)
		#var next_speaker_name = Global.dialog.convos[cur_convo_name]["snippets"][next_snippet_name][0][0]
		#var next_speaker = Global.dialog.speakers[next_speaker_name]
		#next_speaker.join_convo(cur_convo_name, next_snippet_name, 0)
		#cur_choice = 0
		#c.visible = false
	if len(cur_snippet) == cur_snippet_pos + 1: # NO MORE SNIPPETS LEFT AND CURRENT SNIPPET IS OVER
		Global.dialog.end_convo(cur_convo_name)
	else: # CONTINUE ON SAME SNIPPET
		var next_convo_pos = cur_snippet_pos + 1
		var next_speaker_name = cur_snippet[next_convo_pos][0]
		#if cur_snippet[next_convo_pos][0] == "choice":
			#next_speaker_name = "player"
		var next_speaker = Global.dialog.speakers[next_speaker_name]
		next_speaker.join_convo(cur_convo_name, cur_snippet_name, next_convo_pos)
	#bubble.get_node("InteractZ").hide()

func process_input():
	Global.player.npc_input_need = null
	if t.visible_characters != -1:
		finish_text_rolling()
	else:
		Global.player.choice_input_need = false
		next_dialog()

func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)
	
func finish_text_rolling():
	cur_step_per = 0
	step_timer.stop()
	t.visible_characters = -1
	bubble.z_index = 11
	#if cur_line[0] == "choice":
		#var ii_pos = t.position + t.size
		#var panel = t.get_node('Panel').get('theme_override_styles/panel')
		#bubble.get_node("ChoiceLeftArrow").show()
		#bubble.get_node("ChoiceRightArrow").show()
		#var ap = (ii_pos + Vector2(panel.expand_margin_left, 0) + Vector2(15, 0))
		#bubble.get_node("ChoiceLeftArrow").position = -ap + Vector2(0, -t.size.y/2)
		#bubble.get_node("ChoiceRightArrow").position = ap + Vector2(0, -t.size.y/2)
		#bubble.get_node('AnimationPlayer').play("PopUpArrows")
	if cur_line[0] != "choice" and len(cur_line) > 3: # TIMER LINE
		end_timer.start(cur_line[3])
	else: # INTERACT LINE
		Global.player.npc_input_need = self
		
func _on_step_timer_timeout():
	t.visible_characters += 1
	var base_text = t.get_parsed_text()
#	if t.visible_characters != 0 and t.visible_characters != len(base_text):
#		#t.clear()
#		t.text = "[center]" + base_text.substr(0, t.visible_characters-1) + "[pop]" + base_text.substr(t.visible_characters-1, len(base_text) - t.visible_characters + 1) + "[/pop]"
#	else:
#		#t.clear()
#		t.text = "[center]" + base_text
	cur_step_per += 1
	if step_per_letters == cur_step_per:
		Global.player.npc_input_need = self
		cur_step_per = 0
		emit_signal('text_step')
	if t.visible_characters == len(base_text):
		finish_text_rolling()
	else:
		step_timer.start(STEP_SPEED)

func _on_end_timer_timeout():
	next_dialog()

func _on_delay_timer_timeout():
	just_conversed = false
	emit_signal('convo_delay_finished')
