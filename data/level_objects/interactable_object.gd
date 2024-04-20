class_name InteractableObject extends LevelObject

enum InteractionTypes{
	THIEF_UNLOCK = 0, 
	WARRIOR_UNLOCK = 1,
	MAGE_UNLOCK = 2, }


var available_interactions : Array[InteractionTypes] = []


func interact():
	printerr("Method \"interact\" is not declared!")
	return false
