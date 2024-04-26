@icon("./ghost-script.png")
class_name Soul extends Resource

enum SoulType {
	RED = 0,
	GREEN = 1,
	BLUE = 2,
}

@export var name : String
@export var sprite : SpriteFrames
@export var type : SoulType


# var icon = sprite.get_frame_texture("default",0)
var scene = load("res://data/souls_and_currency/soul_scene.tscn") as PackedScene
