class_name BaseMinion extends CharacterBody2D



@export var bound_object : LevelObject

signal minion_dead

func _ready():
	pass
	



func _process(_delta):
	pass

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"scale" : scale
	}
	return save_dict
