class_name BaseHero extends CharacterBody2D



var debug_mode := false

var debug_path : Array[int]

var debug_path_point =0

@export var soul : Soul

@export var speed = 100


var target_reached := false

var on_way_to_final := false



var starting_point_astar : Vector2i



signal target_appeared
signal on_point_reached(point, emmitent)

func _ready():
	await target_appeared
	await get_tree().create_timer(0.01).timeout
	DebugTools.check_null(pathfinder,"PathfinderLogic", self, true)
	DebugTools.check_null(target,"target", self, true)
	_initialise_pathfinding()
	generate_path_map()
	connect_state_machine_functions()

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
	await get_tree().create_timer(0.02).timeout
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
	# 
	# func point_choose_logic(path_variants):
	#	return super(path_variants)	
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
	# print(type_string(typeof(chosen_path)))
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
		path_map = {}
		while path_map == {}:
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

func point_exclude_and_move_on(point_to_exclude):
	# print("called to exclude ", point_to_exclude)
	reset_starting_point(get_parent().global_to_astar(global_position))
	debug_mode = false
	var final_point = known_points_of_interest_global.filter(func(point): return CustomMath.compare_vectors(point, point_to_exclude))[0]
	var final_point_index = known_points_of_interest_global.find(final_point)
	known_points_of_interest_global.pop_at(final_point_index)
	known_points_of_interest_astar.pop_at(final_point_index)
	await generate_path_map(starting_point_astar)
	on_way_to_final = false



func _target_reached():
	assert(false, "Необходимо задать обработку достижения цели")


###########################
# Машина состояний
###########################

@onready var state_chart = $StateChart as StateChart

@onready var enemy_detection_area = $EnemyDetectionArea as Area2D

@onready var interaction_area = $InteractionArea as Area2D

var _available_interactions = [] as Array[InteractableObject.InteractionTypes]

var state_explore := true

var detected_enemy = null


func connect_state_machine_functions():
	enemy_detection_area.body_entered.connect(_on_enemy_detected)
	enemy_detection_area.body_exited.connect(_on_enemy_undetected)
	interaction_area.body_entered.connect(_on_interaction_object_detected)

	# var explore_state = state_chart.get_node("Root").get_node("Explore") as AtomicState
	var attack_state = state_chart.get_node("Root").get_node("Attack") as AtomicState
	attack_state.state_physics_processing.connect(_on_attack_state_physics_processing)
	

func _connect_enemy_death(if_connect:bool, con_func: Callable):
	if detected_enemy.minion_dead.is_connected(con_func):
		if !if_connect:
			detected_enemy.minion_dead.disconnect(con_func)
	else:
		if if_connect:
			detected_enemy.minion_dead.connect(con_func)


func _on_enemy_detected(_body):
	printerr("You should specify \"_on_enemy_detected\" method!")

func _on_enemy_undetected(_body):
	printerr("You should specify \"_on_enemy_undetected\" method!")

func _on_attack_state_physics_processing(_delta):
	# if detected_enemy != null:
		pathfinder.target = detected_enemy
		pathfinder.makepath()
	# else:
	# 	redetect_enemies()

func redetect_enemies():
	var detected_enemies= check_bodies_presence()
	if detected_enemies.size() > 0:
		_on_enemy_detected(detected_enemies[0])
	else:
		_on_enemy_forgotten()

func _on_enemy_forgotten():
	if is_instance_valid(detected_enemy):
		_connect_enemy_death(false,_on_enemy_forgotten)
	state_chart.send_event("enemy_forget")

func _on_attack_state_exited():
	if !is_instance_valid(detected_enemy) or !check_bodies_presence().has(detected_enemy):
		detected_enemy = null
		update_target()
	else:
		await get_tree().create_timer(0.01).timeout
		state_chart.send_event("enemy_detected")

func check_bodies_presence() -> Array:
	return enemy_detection_area.get_overlapping_bodies().filter(func(body):
		return (body!=self and body is CharacterBody2D))


func _on_explore_state_entered():
	detected_enemy = null
	redetect_enemies()
	state_explore = true

func _on_explore_state_exited():
	state_explore = false

func _on_interaction_object_detected(body):
	if body.get_parent() is InteractableObject:
		state_chart.send_event("interaction_required")
		interaction_attempt(body.get_parent())

func interaction_attempt(object : InteractableObject):
	for interaction in _available_interactions:
		if object.available_interactions.has(interaction):
			# FIXME
			target_reached = true
			await get_tree().create_timer(3).timeout
			object.interact()
			break
	if !target_reached:
		# print('fail')
		on_obsticle_interaction_fail()
	else:
		target_reached = false
	state_chart.send_event("interaction_finished")

func find_other_obsitcles():
	return interaction_area.get_overlapping_bodies().filter(func(body):
		return (body!=self and body is InteractableObject))
	
func on_obsticle_interaction_fail():
	if on_way_to_final:
		point_exclude_and_move_on(current_path_map)
	else:
		var points_for_removal = recursive_find_endpoints(current_path_map, [])
		# print("points for removal ",points_for_removal)
		for point in points_for_removal:
			point_exclude_and_move_on(point)
	_init_hero_movement()

func recursive_find_endpoints(points_dict : Dictionary, endpoints : Array) -> Array:
	for point in points_dict.values():
		if point is Dictionary:
			recursive_find_endpoints(point, endpoints)
		else:
			endpoints.append(point)
			return endpoints
	return endpoints

###########################
# Другое
###########################


func _on_death():
	print(self, "is now dead")
	var soul_drop = soul.scene.instantiate()
	soul_drop.soul = soul
	soul_drop.global_position = global_position
	get_parent().add_child(soul_drop)
	queue_free()

var prev_pos = null
var cur_pos = global_position
const STUCK_MARGIN = 10

func _on_stuck_timer_timeout():
	if prev_pos and cur_pos and (prev_pos - cur_pos).length() < STUCK_MARGIN and state_explore:
		update_target()
		if move_and_slide() and find_other_obsitcles().size() >0:
			interaction_attempt(find_other_obsitcles()[0])
	else:
		prev_pos = cur_pos
		cur_pos = global_position

