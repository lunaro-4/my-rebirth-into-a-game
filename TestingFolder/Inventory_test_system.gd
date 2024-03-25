extends Control

@onready var Inventory_level = $"../../MNG"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_pressed():
	Inventory_level._menu_Hide()
	pass # Replace with function body.
