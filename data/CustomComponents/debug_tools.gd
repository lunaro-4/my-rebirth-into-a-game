@icon("res://CustomComponents/CustomComponentIcons/bracket-dot.png")
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
	
