extends CharacterBody2D

var mouse_enter: bool = false
var items = ["Axe", "Book", "Sword"]
var item = ""

func _ready():
	randomize()
	var a = int(randf_range(0,3))
	item = items[a]

func _on_mouse_entered():
	mouse_enter = true
	pass # Replace with function body.


func _on_mouse_exited():
	mouse_enter = false
	pass # Replace with function body.
