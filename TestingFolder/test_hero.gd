extends BaseHero


@onready var pathfinder = $PathfindingLogic as PathfinderLogic

@onready var direction = pathfinder.target_path_vector

var target_reached := false

var wp_first := true

func _ready():
	pathfinder.target = target
	await get_tree().create_timer(0.5).timeout
	
	pathfinder.pathfinding_init()
	#pathfinder.nav_waypoint_reached.connect(reached)
	pass # Replace with function body.

func _physics_process(_delta : float):
	if not target_reached:
		direction = pathfinder.target_path_vector
		velocity = direction * speed
	else:
		velocity = Vector2(0,0)
	move_and_slide()

	



func _reached(_data, waypoint_index): 
	
	if waypoint_index > 0:
		print("вставить мой метод")
		pathfinder.makepath()
	pass


func _on_pathfinding_logic_target_reached():
	print("Я достиг конца пути!")
	target_reached = true
	# FIXME 
	get_tree().quit()
	pass
