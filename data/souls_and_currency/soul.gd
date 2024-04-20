class_name Soul extends Resource


@export var name : String
@export var sprite : SpriteFrames

enum SoulType {
			RED = 0,
			BLUE = 1,
			GREEN = 2,
		}

@export var type : SoulType





var scene = load("res://data/souls_and_currency/soul_scene.tscn") as PackedScene
