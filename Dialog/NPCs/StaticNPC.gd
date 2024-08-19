extends StaticBody3D
class_name StaticNPC3D

@export var speaker_name : String = ""
@export var convo_name : String = ""
@export var noti_name : String = "read"
@export var one_shot : bool = false
@onready var dialog_entity = DialogEntity.new($SubViewport/DialogBubble/RichTextLabel, $SubViewport/DialogBubble/Choices, $SubViewport/DialogBubble)
var cur_pot_convo : String = ""

@export var voice : String = "default"
@export var pitch_shift : float = 1.0
@export var variation : float = 0.1
@export var volume_mod : float = 0.0
@export var etherial : bool = false

@export var lowpass : bool = true
@export var quiet : bool = true

func _ready():
	add_to_group('static_npc')
	$Sprite3D.show()
	add_child(dialog_entity)
	#dialog_entity.connect("text_step", Callable(self, "_on_text_step"))
	dialog_entity.connect("convo_delay_finished", Callable(self, "_on_convo_delay_finished"))
	dialog_entity.connect("convo_finished", Callable(self, "_on_convo_finished"))
	await get_tree().process_frame
	Global.dialog.speakers[speaker_name] = dialog_entity
	cur_pot_convo = convo_name
	
func activate_pot_convo():
	if is_instance_valid(Global.dialog) and cur_pot_convo != "":
		Global.dialog.start_convo(cur_pot_convo)
		Global.player.disable_notis(true)
		
#func _on_text_step():
#	if lowpass:
#		Music.dialoge_lowpass_on = true
#	if quiet:
#		Music.dialoge_amplify_on = true
#	Global.speak(voice, pitch_shift, variation, volume_mod, 4, etherial)

func notify_near(near : bool):
	if cur_pot_convo == "":
		return
	if near:
		$Notifier.noti(noti_name, 0.1)
	else:
		$Notifier.noti("null", 0.1)

func _on_convo_finished(speaker, convo_name):
	#if lowpass:
		#Music.dialoge_lowpass_on = false
	#if quiet:
		#Music.dialoge_amplify_on = false
	if one_shot:
		cur_pot_convo = ""
		
func _on_convo_delay_finished():
#	if lowpass:
#		Music.dialoge_lowpass_on = false
#	if quiet:
#		Music.dialoge_amplify_on = false
	Global.player.disable_notis(false)
