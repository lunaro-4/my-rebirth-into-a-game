extends Treasure

func _ready():
	super()

func interact(interacting_entity):
	if interacting_entity.has_method("on_item_pickup"):
		interacting_entity.on_item_pickup(self)
		queue_free()
		return false
	else:
		return true



