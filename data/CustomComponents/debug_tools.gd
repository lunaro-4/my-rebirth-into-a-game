@icon("./CustomComponentIcons/bracket-dot.png")
class_name DebugTools


"""

PresenceCheck.check(<variable_to_check>, <"ClassStringName">, self)

"""

static func check_null(component : Node, component_name, sender:Node, alert: bool = false):
	if !component:
		var message =str(component_name,  " is not connected at ", sender, ", ",sender.get_parent(),", ",sender.get_parent().get_parent(), " !")
		print(message)
		if alert:
			assert(false, message)

static func check_null_value(value, value_name, sender:Node, alert: bool = false):
	if type_string(typeof(value)) == "Nil":
		var message =str(value_name,  " is not set at ", sender, ", ",sender.get_parent(),", ",sender.get_parent().get_parent(), " !")
		print(message)
		if alert:
			assert(false, message)

static func beautiful_dict_print(dict):
	var int_level = 0
	var tab ='    '
	var text = ''
	dict = str(dict)
	for c in dict:
		match c:
			'{':
				print('\n',tab.repeat(int_level),c)
				int_level+=1
			'}':
				int_level-=1
				print(text)
				text = ''
				print('\n',tab.repeat(int_level),c)
			'[':
				print('\n',tab.repeat(int_level),c)
				int_level+=1
			']':
				int_level-=1
				print(text)
				text = ''
				print('\n',tab.repeat(int_level),c)
			# ']':
			# 	text += c
			# 	print(text)
			# 	text = ''
			':':
				text += c
				print(text)
				text = ''
			_:
				text += c
