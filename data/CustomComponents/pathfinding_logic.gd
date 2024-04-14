class_name PathfinderLogic extends Node2D


###################################
"""

# Костыль К1 - возможность перестраивать путь 
	при достижении точки. Если поставить перестройку
	пути в базовую функцию достижения точки, то 
	путь будет перестраиваться бесконечно и 
	перегрузит стэк

"""
###################################



# Чтобы запустить поиск пути, добавь это сцену в сцену врага,
# И добавь вот эти строчки:

"""

@onready var pathfinder = $PathfindingLogic

# Путь, по которому будет следовать сущность
@onready var direction = pathfinder.target_path_vector

func _ready():
	pathfinder.target =  <ЦЕЛЬ ПОИСКА ПУТИ>
	pathfinder.pathfinding_init()

func _physics_process(_delta : float):
	direction = pathfinder.target_path_vector
	velocity = direction * speed
	move_and_slide()



"""



## Вход для цели пасфайндинга (заполняется автоматически)
@export var target : Node2D

## Выход для пути (куда должна двигаться сущность)
var target_path_vector : Vector2

# Задаем названия для локальных нодов
@onready var nav_agent = $NavigationAgent2D as NavigationAgent2D
@onready var pathfinding_timer = $UpdatePathTimer as Timer


var waypoint_array
var check_map_ready = false

## Сигнал, выдаваемый при достижении точки в поиске пути
signal nav_waypoint_reached(data, waypoint_index)
## Сигнал выдаваемый при достижении конца пути
signal target_reached

## Внутренний сигнал, подключение не безопасно
signal map_ready_sig


func _ready():
	nav_agent.waypoint_reached.connect(waypoint_reached)
	nav_agent.target_reached.connect(path_finished)
	nav_agent.path_changed.connect(path_changed)
	NavigationServer2D.map_changed.connect(map_ready)


func makepath():
	if target == null:
		target_path_vector = Vector2(0,0)
		if get_parent().has_method("animate_sprite"):
			get_parent().is_static = true
	else:
		nav_agent.target_position = target.global_position
		## Далее идет костыль К1
		waypoint_array = nav_agent.get_current_navigation_path()
		set_path_vector(nav_agent.get_current_navigation_path_index())
		target_path_vector = to_local(nav_agent.get_next_path_position()).normalized()


# ОПАСНАЯ ЗОНА
func _process(_delta):
	#_on_path_update_timeout()
	pass


## Обновляет путь, частота регулируется настройками таймера [br][br]
## Лучше выставлять поменьше
func _on_path_update_timeout():
	map_ready_sig.emit()
	set_path_vector(nav_agent.get_current_navigation_path_index())
	pass


## на случай если нужно прекратить поиск пути
func stop_pathfinding():
	pathfinding_timer.stop()


# ...или возобновить поиск пути
func start_pathfinding():
	pathfinding_timer.start()


func pathfinding_init():
	start_pathfinding()
	if not check_map_ready:
		check_map_ready = true
		await map_ready_sig
	makepath()


## Срабатывает при отметке на точке.
## К1 - выдает сигнал, только если расстояние между 
## первыми точками в массиве больше значения.
## В "приемнике" можно безопасно настроить перестройку пути 
func waypoint_reached(data):
	var zero_to_one_length : float
	if waypoint_array:
		zero_to_one_length = (waypoint_array[1] - waypoint_array[0]).length()
	if zero_to_one_length and zero_to_one_length > 5:
		nav_waypoint_reached.emit(data, nav_agent.get_current_navigation_path_index())


## не работает =(
## в приципе и хуй бы с ней
func path_finished():
	stop_pathfinding()
	target_reached.emit()


func set_path_vector(waypoint_index: int):
	waypoint_array = nav_agent.get_current_navigation_path()
	nav_agent.get_next_path_position()
	if nav_agent.get_current_navigation_path() and waypoint_index >0 and waypoint_array.size() > 0:
		target_path_vector = to_local(waypoint_array[waypoint_index]).normalized()
		
	else:
		target_path_vector = to_local(nav_agent.get_next_path_position()).normalized()
	## Замена path_finished
	if (waypoint_array.size() == 3 or waypoint_array.size() == 2) and (
		waypoint_array[waypoint_array.size()-1] - global_position).length() < nav_agent.path_desired_distance:
			path_finished()


func map_ready(_data):
	await get_tree().create_timer(0.1).timeout
	map_ready_sig.emit()


func path_changed():
	pass
