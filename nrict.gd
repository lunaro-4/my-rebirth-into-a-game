@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name red_alert
extends RichTextEffect

var bbcode = "RA"

func _process_custom_fx(char_fx):
	char_fx.color = Color(0,0,0)
	return true




		
