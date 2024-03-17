class_name DetectionArea extends Area2D



@export var target : Node2D

signal target_detected

func _on_area_entered(area):
	#print("area found!", "  ", area, "  ", area.get_parent(), "  ", target)
	if (area is HurtBoxComponent) and (area.get_parent() == target):
		#print("area is correct1", "  ", area)
		target_detected.emit()
	
	pass 

