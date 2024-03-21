extends Control
@onready var text = $MarginContainer2/MarginContainer/Label
@onready var timer = $Timer

var letter_time = 0.01
var punct_time = 0.8
var space_time = 0.1
# Called when the node enters the scene tree for the first time.
func _ready():
	text.visible_ratio = 0
	timer.start(letter_time)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_timer_timeout():
	text.visible_ratio += 0.005
	pass # Replace with function body.
