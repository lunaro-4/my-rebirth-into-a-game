extends Node2D

var item = ""

signal on_pick()


func set_item(item_name):
	$TextureButton.texture_normal = load("res://assets/icons/%s.png" % item_name)
	item = item_name
	
		
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_pressed():
	on_pick.emit()
	get_parent().remove_child(self)
	pass # Replace with function body.
