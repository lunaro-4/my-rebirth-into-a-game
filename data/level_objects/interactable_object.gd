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
