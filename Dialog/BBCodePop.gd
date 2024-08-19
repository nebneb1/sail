@tool
extends RichTextEffect
class_name RichTextPop

var bbcode := "pop"
var custom_time : float = 0.0
var prev_char
func _process_custom_fx(char_fx):
	if char_fx != prev_char:
		prev_char = char_fx
		custom_time = 0.0
	custom_time += 0.001
	var offset := Vector2(0, -2)#-4*sin(custom_time * 100))
	char_fx.offset = offset
	return true
