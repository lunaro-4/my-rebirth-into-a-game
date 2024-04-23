class_name InteractableObject extends Node2D

@export var interaction_distance : int

enum InteractionTypes{
	DEFAULT,
	THIEF_UNLOCK, 
	WARRIOR_UNLOCK,
	MAGE_UNLOCK, 
	PICKUP,


	}



var available_interactions : Array[InteractionTypes] = []


func interact(_interacting_entity):
	printerr("Method \"interact\" is not declared!")
	return true

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"scale" : scale
	}
	return save_dict
