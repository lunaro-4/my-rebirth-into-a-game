extends Node2D

@onready var texture_trup = "res://TestingFolder/textbox.png"
@onready var trup = $Trup/Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_trup_mouse_entered():
	trup.texture = "res://TestingFolder/textbox.png"
	pass # Replace with function body.
