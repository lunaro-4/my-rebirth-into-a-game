extends Node2D

@onready var texture_trup = preload("res://TestingFolder/textbox.png")
@onready var texture_JIV = preload("res://icon.svg")
@onready var inventory_texture = preload("res://TestingFolder/red.png")
@onready var trup = $Trup/Sprite2D
@onready var Trupeshnik = $CharacterBody2D
@onready var Inventory = $CanvasLayer/Control

var mouse_entered: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	Inventory.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ((Trupeshnik.global_position - trup.global_position).length() < 200 
	and mouse_entered == true): 
		trup.set_texture(texture_trup)
		_Click_on_inventory()
	else:
		trup.set_texture(texture_JIV)
	pass



func _on_trup_mouse_entered():
	mouse_entered = true
	pass # Replace with function body.

 
func _on_trup_mouse_exited():
	mouse_entered = false
	
func _Click_on_inventory():
	if Input.is_action_pressed("Right_Mouse_Button"):
		Inventory.show()
		

