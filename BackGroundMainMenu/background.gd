extends Node

var speed = 20
@onready var PL = $ParallaxBackground
@onready var PL1 = $ParallaxBackground2
@onready var PL2 = $ParallaxBackground3
@onready var PL3 = $ParallaxBackground4
@onready var island = $ParallaxBackground6

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	PL.scroll_offset.x -= speed * delta
	PL1.scroll_offset.x -= speed * delta * 1.2
	PL2.scroll_offset.x -= speed * delta / 1.5
	PL3.scroll_offset.x -= speed * delta / 2
	island.scroll_offset.x -= speed * delta / 4
	pass
