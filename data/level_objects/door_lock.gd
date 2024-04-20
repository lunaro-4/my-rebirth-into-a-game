extends InteractableObject

func _ready():
	available_interactions.append(InteractionTypes.THIEF_UNLOCK)

func interact():
	queue_free()
