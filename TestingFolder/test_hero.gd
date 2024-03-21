extends BaseHero


@onready var pathfinder = $PathfindingLogic as PathfinderLogic

@onready var direction = pathfinder.target_path_vector

func _ready():
	pathfinder.target = target
	await get_tree().create_timer(3).timeout
	pathfinder.pathfinding_init()
	#pathfinder.nav_waypoint_reached.connect(reached)
	pass # Replace with function body.

func _physics_process(_delta : float):
	direction = pathfinder.target_path_vector
	velocity = direction * speed
	move_and_slide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func _reached(data):
	print("reached!")
	print(data)
