class_name TestHero extends BaseHero


@onready var pathfinder = $PathfindingLogic as PathfinderLogic

@onready var direction = pathfinder.target_path_vector

@export var target : Node2D

@export var speed = 100

var target_reached := false

var wp_first := true

signal target_appeared

func _ready():
	_initialise_pathfinding()

func _physics_process(_delta : float):
	if not target_reached:
		direction = pathfinder.target_path_vector
		velocity = direction * speed
	else:
		velocity = Vector2(0,0)
	move_and_slide()

func _initialise_pathfinding():
	if get_parent().has_signal("points_established"):
		get_parent().points_established.connect(target_ready)
	if !target:
		await target_appeared
	pathfinder.target = target
	pathfinder.pathfinding_init()

func target_ready():
	target_appeared.emit()

func _reached(_data, waypoint_index): 
	if waypoint_index > 0:
		print("вставить мой метод")
		pathfinder.makepath()
	pass


func _on_pathfinding_logic_target_reached():
	print("Я достиг конца пути!")
	target_reached = true
	# FIXME 
	#get_tree().quit()
	pass
