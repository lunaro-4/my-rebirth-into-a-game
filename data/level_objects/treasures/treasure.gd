@icon("./gold-fillerd.png")
class_name Treasure extends InteractableObject



func _ready():
	available_interactions.append(InteractableObject.InteractionTypes.PICKUP)
