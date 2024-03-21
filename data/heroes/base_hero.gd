class_name BaseHero extends CharacterBody2D

@export var target : Node2D

#@onready var pathfinder = $PathfindingLogic as PathfinderLogic

#@onready var direction = pathfinder.target_path_vector

var speed = 100

func _ready():
	#pathfinder.target = target
	#pathfinder.pathfinding_init()
	#pathfinder.nav_waypoint_reached.connect(reached)
	##await get_tree().create_timer(3).timeout
	pass # Replace with fun	passction body.





func _process(delta):
	pass


func reached():
	print("reached!")
