extends CharacterBody2D

@onready var run = $AnimatedSprite2D
@onready var label = $Label
@onready var timer = $Timer

var mouse: bool = true
var count = 0 
var time = 0.1
func _ready():
	label.modulate.a = 0
	label.position.y = 160
	
func _process(delta):
	if label.position.y >= 220:
		timer.stop()
	pass
	


func _on_mouse_entered():
	count += 1
	if count == 1:
		run.play("Run")
		timer.start(time)
	if count >=2:
		run.play("Run_stop")
pass # Replace with function body.


func _on_mouse_exited():
	run.play("Run_exit")
	pass # Replace with function body.

func _label_timer():
	pass

func _on_timer_timeout():
	label.modulate.a += 0.3
	label.position.y += 15
	pass # Replace with function body.
