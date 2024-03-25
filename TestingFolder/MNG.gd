extends Node

@onready var Inventory_hide = $"../CanvasLayer/Control"
@onready var Item = preload("res://TestingFolder/items.tscn")
@onready var slot = $"../CanvasLayer/Control/GridContainer/Slot"

var item_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_random_items()
	pass # Replace with function body.

func _random_items():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _menu_Hide():
	Inventory_hide.hide()

func get_player():
	return $"../CharacterBody2D"


