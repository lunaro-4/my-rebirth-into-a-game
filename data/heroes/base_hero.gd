class_name BaseHero extends CharacterBody2D



# @onready var pathfinder = $PathfindingLogic as PathfinderLogic

#@onready var direction = pathfinder.target_path_vector


func _ready():
	#pathfinder.target = target
	#pathfinder.pathfinding_init()
	#pathfinder.nav_waypoint_reached.connect(reached)
	##await get_tree().create_timer(3).timeout
	pass # Replace with fun	passction body.

func reached():
	print("reached!")
