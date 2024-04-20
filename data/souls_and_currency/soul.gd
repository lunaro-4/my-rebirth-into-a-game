class_name Soul extends Resource


@export var name : String
@export var sprite : SpriteFrames
enum SoulType {RED, BLUE, GREEN}
@export var type : SoulType





var scene = load("res://data/souls_and_currency/soul_scene.tscn") as PackedScene
