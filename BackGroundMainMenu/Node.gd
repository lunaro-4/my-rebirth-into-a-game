extends Node

var speed = 100 
@onready var PL1 = $ParallaxBackground5
@onready var PL2 = $ParallaxBackground

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	PL1.scroll_ofset.x = speed * delta
	PL2.scroll_ofset.x = speed * delta
	pass
