@icon("./gold-fillerd.png")
class_name Treasure extends InteractableObject


@onready var collision = %CollisionShape as CollisionShape2D

var treasure_index : int


func _ready():
	available_interactions.append(InteractableObject.InteractionTypes.PICKUP)

func interact(interacting_entity):
	if interacting_entity.has_method("on_item_pickup"):
		interacting_entity.on_item_pickup(self)
		visible = false
		collision.disabled = true
		add_to_group("stolen")
		return false
	else:
		return true
