class_name BaseHero extends CharacterBody2D



var debug_mode := false

var debug_path : Array[int]

var debug_path_point =0


@export var speed = 100


var target_reached := false

var on_way_to_final := false


var starting_point_astar : Vector2i



signal target_appeared
signal on_point_reached(point, emmitent)

func _ready():
	await target_appeared
	await get_tree().create_timer(0.01).timeout
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


func point_choose_logic(path_variants):
	# printerr("У героя должен быть метод point_choose_logic, определяющий логику нахождения следующей точки")
	# printerr("Использую метод рандомного поиска")
	return path_variants[randi()%path_variants.size()]


## Логика нахождения следующей точки [br][br]
## Если включен дебаг мод, можно передать индексы выбираемых путей.
## Логика выбора следующей точки прописана в методе point_choose_logic [br][br]
## По умолчанию, point_choose_logic выбирает рандомное направление
func get_next_point():
	var path_variants = current_path_map[current_path_map.keys()[0]]
	# Если передать словарь с ключом с одним значением, обработать это значение как точку.
	if not path_variants is Array:
		get_parent().set_new_point_for_hero(path_variants, self)
		update_target()
		return
	var chosen_path
	if debug_mode:
		chosen_path = path_variants[debug_path[debug_path_point]]
		debug_path_point +=1
	else:
		chosen_path = point_choose_logic(path_variants)
	# Здесь задается следующая точка маршрута, исходя из выбранного пути
	var chosen_point = KEY_NONE
	print(type_string(typeof(chosen_path)))
	print(chosen_path)
	if chosen_path is Dictionary:
		chosen_point = chosen_path.keys()[0]
	else:
		chosen_point = chosen_path
		on_way_to_final = true
	current_path_map = chosen_path
	get_parent().set_new_point_for_hero(chosen_point, self)
	update_target()

func _init_hero_movement(start_from = starting_point_astar):
	current_path_map = path_map
	if debug_mode:
		if !debug_path:
			assert(false, "debug path not provided")
	if CustomMath.is_vector_in_array(start_from,path_map.keys()):
		get_next_point()
	else:
		get_parent().set_new_point_for_hero(path_map.keys()[0], self)
		update_target()
	target_ready()	


func generate_path_map(map_starting_point = starting_point_astar):
	if poic:
		path_map=poic.generate_path_map(map_starting_point, known_points_of_interest_astar)
	else:
		assert(false, str("no poic at", self))

###########################
# Обработка хождения по лабиринту
###########################



func reset_starting_point(new_point_astar):
	starting_point_astar = new_point_astar

func _reached(_data, _waypoint_index): 
	# print("вставить мой метод")
	pass



func _target_reached():
	assert(false, "Необходимо задать обработку достижения цели")
