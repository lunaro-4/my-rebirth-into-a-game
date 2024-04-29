class_name LevelObject extends Resource

enum ObjectType {
	OBSTACLE = 0,
	TREASURE = 1,
	ENEMY = 2,
	WALL = 99,
	}

@export var name : String
@export var object_scene : PackedScene
@export var icon : Image
@export var type : ObjectType
@export var scale : float
@export var recepie : Array[Soul]
var soul_costs : Dictionary

# var iccco = ScenePreviewExtractor.get_preview(object_scene,self,"set_texture")

func _translate_recepie():
	if type != ObjectType.TREASURE:
		var path_array = []
		for soul in recepie:
			path_array.append(soul.resource_path)
		return path_array
	else:
		var path_dict = {}
		for soul in recepie:
			path_dict [soul.resource_path] = soul_costs [soul]
		return path_dict

func save() -> Dictionary:
	var save_dict= {
		"name" = name,
		"object_scene" = object_scene.resource_path,
		"icon" = icon.resource_path,
		"type" = type,
		"scale" = scale,
		"recepie" = _translate_recepie()
	}
	return save_dict

func get_scene_instance() -> Node2D:
	var new_scene_instance = object_scene.instantiate()
	new_scene_instance.bound_object = self
	return new_scene_instance

func is_equal_to(other_object : LevelObject) -> bool:
	return recepie == other_object.recepie
