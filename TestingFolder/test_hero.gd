class_name TestHero extends BaseHero


@onready var pathfinder = $PathfindingLogic as PathfinderLogic

@onready var direction = pathfinder.target_path_vector

@export var target : Node2D

@export var speed = 100

@export var path_map : Dictionary

var current_path_map

var target_reached := false

var wp_first := true

var on_way_to_final := false



var debug_mode := false

var debug_path : Array[int]

var debug_path_point =0


signal target_appeared
signal on_point_reached(point, emmitent)

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
	await get_tree().create_timer(0.01).timeout
	pathfinder.target_reached.connect(_target_reached)
	update_target()

func target_ready():
	target_appeared.emit()


func update_target():
	pathfinder.target = target
	pathfinder.pathfinding_init()




func _handle_path_change():
	pass

func get_next_point():
	var path_variants = current_path_map[current_path_map.keys()[0]]
	var chosen_path
	if debug_mode:
		chosen_path = path_variants[debug_path[debug_path_point]]
		debug_path_point +=1
	else:
		chosen_path = path_variants[randi()%path_variants.size()]
	var chosen_point = KEY_NONE
	if chosen_path is Dictionary:
		chosen_point = chosen_path.keys()[0]
		current_path_map = chosen_path
		# print(chosen_point)
	else:
		chosen_point = chosen_path
		on_way_to_final = true
	get_parent().set_new_point_for_hero(chosen_point, self)
	update_target()

func _init_hero_movement(starting_point: Vector2i):
	if debug_mode:
		if !debug_path:
			assert(false)
	if CustomMath.is_vector_in_array(starting_point,path_map.keys()):
		current_path_map = path_map
		get_next_point()
	else:
		get_parent().set_new_point_for_hero(path_map.keys()[0])
		update_target()
	target_ready()	








func _reached(_data, _waypoint_index): 
	if _waypoint_index > 0:
		# print("вставить мой метод")
		pathfinder.makepath()
	pass


func _target_reached():
	print("Я достиг конца пути!")
	if on_way_to_final:
		target_reached=true
	else:
		get_next_point()
	# target_reached = true
	# FIXME 
	#get_tree().quit()
