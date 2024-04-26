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

# var iccco = ScenePreviewExtractor.get_preview(object_scene,self,"set_texture")
