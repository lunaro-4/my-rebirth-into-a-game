extends Obstacle

func _ready():
	available_interactions.append(InteractionTypes.THIEF_UNLOCK)

func interact(_interacting_entity):
	queue_free()
	return false
