class_name BaseHero extends CharacterBody2D



var debug_mode := false

var debug_path : Array[int]

var debug_path_point =0

@export var soul : Soul

@export var speed = 100


var target_reached := false

var on_way_to_final := false

var soul_value



var starting_point_astar : Vector2i



signal target_appeared
signal on_point_reached(point, emmitent)

func _ready():
	await target_appeared
	await get_tree().create_timer(0.01).timeout
	DebugTools.check_null(pathfinder,"PathfinderLogic", self, true)
	DebugTools.check_null(exploration_target,"exploration_target", self, true)
	_initialise_pathfinding()
	_generate_path_map()
	_connect_state_machine_functions()

func _physics_process(_delta : float):

	pass


###########################
# Поиск пути
###########################

@export var exploration_target : Node2D

@onready var pathfinder = $PathfindingLogic as PathfinderLogic


@onready var direction = pathfinder.target_path_vector

func _initialise_pathfinding():
	get_parent().set_new_point_for_hero(Vector2i(0,0), self)
	if get_parent().has_signal("points_established"):
		get_parent().points_established.connect(target_ready)
	pathfinder.path_finished.connect(_target_reached)
	pathfinder.waypoint_reached.connect(_reached)
	update_target(exploration_target)

func target_ready():
	target_appeared.emit()


func update_target(target_to_set):
	await get_tree().create_timer(0.02).timeout
	pathfinder.target = target_to_set
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
	if path_variants == null:
		on_way_to_final = true
		var final_point = current_path_map.keys() [0]
		current_path_map = final_point
		get_parent().set_new_point_for_hero(final_point, self)
		update_target(exploration_target)
		return
	if not path_variants is Array and not path_variants is PackedVector2Array:
		if path_variants is Vector2 or path_variants is Vector2i:
			on_way_to_final = true
		get_parent().set_new_point_for_hero(path_variants, self)
		update_target(exploration_target)
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
	update_target(exploration_target)

func _init_hero_movement(start_from = starting_point_astar):
	current_path_map = path_map
	if debug_mode:
		if !debug_path:
			assert(false, "debug path not provided")
	if CustomMath.is_vector_in_array(start_from,path_map.keys()):
		get_next_point()
	else:
		get_parent().set_new_point_for_hero(path_map.keys()[0], self)
		update_target(exploration_target)
	target_ready()	


func _generate_path_map(map_starting_point = starting_point_astar):
	if poic:
		if known_points_of_interest_astar.size() <=0:
			_target_reached()
			return
		path_map = {}
		while path_map == {}:
			path_map=poic.generate_path_map(map_starting_point, known_points_of_interest_astar)
			if not path_map.keys() [0] is Vector2 and not path_map.keys() [0] is Vector2i:
				assert(false)
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

func _point_exclude_and_move_on(point_to_exclude):
	# print("called to exclude ", point_to_exclude)
	reset_starting_point(get_parent().global_to_astar(global_position))
	debug_mode = false
	var final_point = known_points_of_interest_global.filter(func(point): return CustomMath.compare_vectors(point, point_to_exclude))
	if final_point.size() >0:
		final_point = final_point[0]
		var final_point_index = known_points_of_interest_global.find(final_point)
		known_points_of_interest_global.pop_at(final_point_index)
		known_points_of_interest_astar.pop_at(final_point_index)
		await _generate_path_map(starting_point_astar)
		on_way_to_final = false



func _target_reached():
	assert(false, "Необходимо задать обработку достижения цели")


###########################
# Машина состояний
###########################

enum State {
	EXPLORE,
	ATTACK,
	INTERACT,
	MOVE_TO_INTERACT
}

var current_state : State
var state_explore := true
var detected_enemy = null
var is_able_to_move := true

@onready var state_chart = $StateChart as StateChart
@onready var enemy_detection_area = $EnemyDetectionArea as Area2D
@onready var obstacle_detection_area = $ObstacleDetectionArea as Area2D
@onready var interactable_detection_area = $InteractableDetectionArea as Area2D

func _connect_state_machine_functions():
	enemy_detection_area.body_entered.connect(_on_enemy_detected)
	enemy_detection_area.body_exited.connect(_on_enemy_undetected)
	obstacle_detection_area.body_entered.connect(_on_obstacle_detected)
	interactable_detection_area.body_entered.connect(_on_interactable_detected)

	var explore_state = state_chart.get_node("Root").get_node("Explore") as AtomicState
	var attack_state = state_chart.get_node("Root").get_node("Attack") as AtomicState
	var move_to_interact = state_chart.get_node("Root").get_node("MoveToInteract") as AtomicState
	var interact = state_chart.get_node("Root").get_node("Interact") as AtomicState
	attack_state.state_physics_processing.connect(_on_attack_state_physics_processing)
	# attack_state.state_entered.connect(_on_attack_state_entered)
	attack_state.state_exited.connect(_on_attack_state_exited)
	explore_state.state_physics_processing.connect(_on_explore_state_physics_processing)
	explore_state.state_entered.connect(_on_explore_state_entered)
	explore_state.state_exited.connect(_on_explore_state_exited)
	move_to_interact.state_physics_processing.connect(_on_move_to_interact_physics_processing)
	interact.state_entered.connect(_on_interact_state_entered)
	interact.state_exited.connect(_on_interact_state_exited)
	state_chart.send_event("interaction_required")
	# state_chart.send_event("in_interaction_radius")
	state_chart.send_event("interaction_finished")

func _move():
	if is_able_to_move:
		direction = pathfinder.target_path_vector
		velocity = direction * speed
	else:
		velocity = Vector2(0,0)
	move_and_slide()
	
##########
# Состояние исследования 
##########

func _on_explore_state_physics_processing(_delta:float):
	# print('yes')
	current_state = State.EXPLORE
	if not target_reached:
		# update_target(exploration_target)
		_path_update_counter(_delta)
		_move()

func _path_update_counter(count_add):
	path_update_counter += count_add
	if path_update_counter > 3:
		pathfinder.makepath()
		path_update_counter = 0

func _on_explore_state_entered():
	detected_enemy = null
	_redetect_enemies()
	var nearby_interactable_objects = _redetect_interactable_objects()
	if nearby_interactable_objects.size() > 0:
		print('found')
		state_chart.send_event("interaction_required")
	elif detected_enemy == null:
		state_explore = true
		update_target(exploration_target)

func _on_explore_state_exited():
	state_explore = false


##########
# Состояние атаки
##########

func _on_attack_state_physics_processing(_delta):
	current_state = State.ATTACK
	update_target(detected_enemy)
	_move()

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


func _redetect_enemies():
	var detected_enemies= _find_other_minions()
	if detected_enemies.size() > 0:
		_on_enemy_detected(detected_enemies[0])
	else:
		_on_enemy_forgotten()

func _on_enemy_forgotten():
	if is_instance_valid(detected_enemy):
		_connect_enemy_death(false,_on_enemy_forgotten)
	state_chart.send_event("enemy_forget")

func _on_attack_state_exited():
	if !is_instance_valid(detected_enemy) or !_find_other_minions().has(detected_enemy):
		detected_enemy = null
	else:
		await get_tree().create_timer(0.01).timeout
		state_chart.send_event("enemy_detected")

func _find_other_minions() -> Array:
	return enemy_detection_area.get_overlapping_bodies().filter(func(body):
		return (body!=self and body is BaseMinion))


##########
# Состояние взаимодействия с объектами
##########

var object_to_interact : Node2D

var path_update_counter = 0

var _available_interactions = [InteractableObject.InteractionTypes.PICKUP] as Array[InteractableObject.InteractionTypes]

var is_interaction_valid := false

signal interacting_initialised

func _on_interact_state_entered():
	interacting_initialised.emit()

func _on_interact_state_exited():
	pass

func _on_move_to_interact_physics_processing(_delta:float):
	current_state = State.MOVE_TO_INTERACT
	if is_instance_valid(object_to_interact) and object_to_interact:
		var distance_to_object = (object_to_interact.global_position - global_position).length()
		if object_to_interact.interaction_distance < distance_to_object:
			update_target(object_to_interact)
			_move()
		else:
			# print(distance_to_object, object_to_interact.global_position,global_position)
			state_chart.send_event("in_interaction_radius")
			current_state = State.INTERACT
	else:
		# state_chart.send_event("interaction_finished")
		pass

func on_item_pickup(item):
	print("Picked up ", item)

func _on_obstacle_detected(body):
	if body.get_parent() is Obstacle:
		state_chart.send_event("interaction_required")
		object_to_interact = body.get_parent()
		_interaction_attempt(object_to_interact)

func _on_interactable_detected(body):
	if not body.get_parent() is Obstacle:
		state_chart.send_event("interaction_required")
		object_to_interact = body.get_parent()
		_interaction_attempt(object_to_interact)

func _interaction_process():
	printerr("\"_interacion_process\" is not overriden!")
	await get_tree().create_timer(2).timeout

func _interaction_attempt(object : InteractableObject):
	var interaction_success := false
	for interaction in _available_interactions:
		if object.available_interactions.has(interaction):
			await interacting_initialised
			await _interaction_process() 
			var interaction_outcome = object.interact(self)
			if interaction_outcome == null or interaction_outcome == false:
				interaction_success = true
			break
	if !interaction_success:
		_on_obstacle_interaction_fail()
	state_chart.send_event("interaction_finished")

func _find_other_obstacles() -> Array:
	return obstacle_detection_area.get_overlapping_bodies().filter(func(body):
		return (body!=self and body.get_parent() is InteractableObject))

func _redetect_interactable_objects() -> Array:
	return interactable_detection_area.get_overlapping_bodies().filter(func(body):
		return (body!=self and body.get_parent() is InteractableObject))
	
func _on_obstacle_interaction_fail():
	if on_way_to_final:
		_point_exclude_and_move_on(current_path_map)
	else:
		var points_for_removal = _recursive_find_endpoints(current_path_map, [])
		# print("points for removal ",points_for_removal)
		for point in points_for_removal:
			_point_exclude_and_move_on(point)
	_init_hero_movement()

func _recursive_find_endpoints(points_dict : Dictionary, endpoints : Array) -> Array:
	for point in points_dict.values():
		if point is Dictionary:
			_recursive_find_endpoints(point, endpoints)
		else:
			endpoints.append(point)
			return endpoints
	return endpoints


###########################
# Другое
###########################


func _on_death():
	call_deferred("_die")

func _die():
	print(self, "is now dead")
	var soul_drop = soul.scene.instantiate()
	soul_drop.soul = soul
	soul_drop.global_position = global_position
	soul_drop.soul_value = soul_value
	soul_drop.soul_collected.connect(get_parent()._on_soul_collected.bind(soul_drop))

	soul_drop.add_to_group("soul_drop")
	get_parent().add_child(soul_drop)
	queue_free()
	pass

var prev_pos = null
var cur_pos = global_position
const STUCK_MARGIN = 10

func _on_stuck_timer_timeout():
	return
	# if prev_pos and cur_pos and (prev_pos - cur_pos).length() < STUCK_MARGIN and state_explore:
	# 	update_target(exploration_target)
	# 	if _find_other_obstacles().size() >0:
	# 		_interaction_attempt(_find_other_obstacles()[0])
	# else:
	# 	prev_pos = cur_pos
	# 	cur_pos = global_position





