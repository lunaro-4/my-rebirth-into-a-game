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
var active := false
var chase_state := false

## Сигнал, выдаваемый при достижении точки в поиске пути
signal waypoint_reached(data, waypoint_index)
## Сигнал выдаваемый при достижении конца пути
signal path_finished
signal path_changed

## Внутренний сигнал, подключение не безопасно
signal map_ready_sig


func _ready():
	nav_agent.waypoint_reached.connect(on_waypoint_reached)
	nav_agent.target_reached.connect(on_path_finished)
	nav_agent.path_changed.connect(on_path_changed)
	NavigationServer2D.map_changed.connect(map_ready)


func makepath():
	
	if target == null or !active:
		target_path_vector = Vector2(0,0)
		if get_parent().has_method("animate_sprite"):
			get_parent().is_static = true
	else:
		nav_agent.target_position = target.global_position
		## Далее идет костыль К1
		waypoint_array = nav_agent.get_current_navigation_path()
		# set_path_vector(nav_agent.get_current_navigation_path_index())
		# set_path_vector(1)
		target_path_vector = to_local(nav_agent.get_next_path_position()).normalized()


# ОПАСНАЯ ЗОНА
func _physics_process(_delta):
	if active:
		target_path_vector = to_local(nav_agent.get_next_path_position()).normalized()
		if check_map_ready:
			# _on_path_update_timeout()
			pass
		pass


## Обновляет путь, частота регулируется настройками таймера [br][br]
## Лучше выставлять поменьше
func _on_path_update_timeout():
	map_ready_sig.emit()
	# set_path_vector(nav_agent.get_current_navigation_path_index())
	if chase_state:
		makepath()
	pass

func start_chase(chase_target):
	chase_state = true	
	target = chase_target	


func end_chase(other_target):
	chase_state = false	
	target = other_target	

## на случай если нужно прекратить поиск пути
func stop_pathfinding():
	pathfinding_timer.stop()
	active = false


# ...или возобновить поиск пути
func start_pathfinding():
	pathfinding_timer.start()
	active = true


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
## FIXME навигатор до сих пор иногда проскакивает через точку 1
## Нужно будет переделать, чтобы он ходил по массиву сам,
## а в этом методе считал индекс
func on_waypoint_reached(data):
	if !active:
		return
	# print("reached")
	# var zero_to_one_length : float
	# if waypoint_array:
	# 	zero_to_one_length = (waypoint_array[1] - waypoint_array[0]).length()
	waypoint_array = nav_agent.get_current_navigation_path()
	# if zero_to_one_length and zero_to_one_length > 2:
	var current_path_index = nav_agent.get_current_navigation_path_index()
	waypoint_reached.emit(data, current_path_index)
	if waypoint_array.size() >0 and (waypoint_array[-1] - global_position).length() < nav_agent.path_desired_distance:
			on_path_finished()
			return

## не работает =(
## в приципе и хуй бы с ней
func on_path_finished():
	if !active:
		return
	stop_pathfinding()
	path_finished.emit()




func map_ready(_data):
	await get_tree().create_timer(0.1).timeout
	map_ready_sig.emit()


func on_path_changed():
	path_changed.emit()
	pass
