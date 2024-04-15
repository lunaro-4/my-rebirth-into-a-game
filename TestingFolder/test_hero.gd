class_name TestHero extends BaseHero


var debug_mode := false

var debug_path : Array[int]

var debug_path_point =0


@export var speed = 100


var target_reached := false

var on_way_to_final := false


var starting_point = Vector2i(global_position)


# TODO он больше не ходит(
signal target_appeared
signal on_point_reached(point, emmitent)

func _ready():
	await target_appeared
	await get_tree().create_timer(0.01).timeout
	# print(pathfinder)
	# print(pathfinder.get_class())
	if !pathfinder:
		assert(false)
	if !target:
		assert(false)
	_initialise_pathfinding()
	generate_path_map()

func _physics_process(_delta : float):
	if not target_reached:
		direction = pathfinder.target_path_vector
		velocity = direction * speed
	else:
		velocity = Vector2(0,0)
	move_and_slide()



###########################
# Поиск пути
###########################

@export var target : Node2D

@onready var pathfinder = $PathfindingLogic as PathfinderLogic


@onready var direction = pathfinder.target_path_vector

func _initialise_pathfinding():
	get_parent().set_new_point_for_hero(Vector2i(0,0), self)
	if get_parent().has_signal("points_established"):
		get_parent().points_established.connect(target_ready)
	pathfinder.path_finished.connect(_target_reached)
	pathfinder.waypoint_reached.connect(_reached)
	update_target()

func target_ready():
	target_appeared.emit()


func update_target():
	pathfinder.target = target
	pathfinder.pathfinding_init()


###########################
# Обработка карты путей
###########################

@export var path_map : Dictionary

## Points Of Interest Component
@export var poic : PointsOfInterestComponent

var known_points_of_interest_astar

var known_points_of_interest_global

var current_path_map

func get_next_point():
	var path_variants = current_path_map[current_path_map.keys()[0]]
	if not path_variants is Array:
		get_parent().set_new_point_for_hero(path_variants, self)
		update_target()
		return
	var chosen_path
	if debug_mode:
		chosen_path = path_variants[debug_path[debug_path_point]]
		debug_path_point +=1
	else:
		chosen_path = path_variants[randi()%path_variants.size()]
	var chosen_point = KEY_NONE
	if chosen_path is Dictionary:
		chosen_point = chosen_path.keys()[0]
		# print(chosen_point)
	else:
		chosen_point = chosen_path
		on_way_to_final = true
	current_path_map = chosen_path
	get_parent().set_new_point_for_hero(chosen_point, self)
	update_target()

func _init_hero_movement(start_from = starting_point):
	current_path_map = path_map
	if debug_mode:
		if !debug_path:
			assert(false)
	if CustomMath.is_vector_in_array(start_from,path_map.keys()):
		get_next_point()
	else:
		get_parent().set_new_point_for_hero(path_map.keys()[0], self)
		update_target()
	target_ready()	


func generate_path_map(map_starting_point = starting_point):
	if poic:
		path_map=poic.generate_path_map(map_starting_point, known_points_of_interest_astar)
	else:
		print('no poic(')

###########################
# Обработка хождения по лабиринту
###########################



func reset_starting_point():
	starting_point = Vector2i(global_position)

func _reached(_data, _waypoint_index): 
	# if _waypoint_index > 0:
	# print("вставить мой метод")
	# pathfinder.makepath()
	pass


func _target_reached():
	# print("Я достиг конца пути!")
	if target_reached:
		return

	if known_points_of_interest_astar.size() < 2:
		target_reached = true
		pathfinder.stop_pathfinding()
		return
	if on_way_to_final:
		reset_starting_point()
		debug_mode = false
		var final_point = known_points_of_interest_global.filter(func(point): return CustomMath.compare_vectors(point, current_path_map))[0]
		var final_point_index = known_points_of_interest_global.find(final_point)
		known_points_of_interest_global.pop_at(final_point_index)
		var current_point = known_points_of_interest_astar.pop_at(final_point_index)
		on_way_to_final = false
		await generate_path_map(current_point)
		_init_hero_movement()
	else:
		get_next_point()
	pathfinder.makepath()
	# target_reached = true
	# FIXME 
	#get_tree().quit()



