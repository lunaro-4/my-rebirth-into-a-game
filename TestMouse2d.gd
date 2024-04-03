extends CharacterBody2D

@onready var run = $AnimatedSprite2D
@onready var label = $Label
@onready var timer = $Timer
@onready var perehod = preload("res://BackGroundMainMenu/perehod.tscn")
@onready var TimerChange = $TimerChange

var mouse: bool = false
var count = 0 
var time = 0.1

func _ready():
	label.modulate.a = 0
	
func _process(delta):
	if label.position.y >= 40:
		timer.stop()
	if mouse == true:
		if Input.is_action_just_pressed("Left_Mouse_Button"):
			TimerChange.start()
			var perehod_2 = perehod.instantiate()
			get_parent().get_children()[-1].add_sibling(perehod_2)
			#add_child(perehod_2)
	pass
	
func _on_mouse_entered():
	mouse = true
	count += 1
	if count == 1:
		run.play("Run")
		timer.start(time)
	if count >=2:
		run.play("Run_stop")
	
func _on_mouse_exited():
	mouse = false
	run.play("Run_exit")
	pass # Replace with function body.

func _on_timer_timeout():
	label.modulate.a += 0.25
	label.position.y += 10
	pass # Replace with function body.


func _on_timer_change_timeout():
	get_tree().change_scene_to_file("res://TestingFolder/testing_level.tscn")
	pass # Replace with function body.
