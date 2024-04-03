extends Node2D

@onready var timer = $Timer1
@onready var color = $ColorRect


var timer_timer = 0.05
# Called when the node enters the scene tree for the first time.
func _ready():
	color.modulate.a = 0
	timer.start(timer_timer)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	color.modulate.a += 0.05

	if color.modulate.a >= 1:
		timer.stop()
		get_tree().change_scene_to_file("res://TestingFolder/testing_level.tscn")
	pass # Replace with function body.

