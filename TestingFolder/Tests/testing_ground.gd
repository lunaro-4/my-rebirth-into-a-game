extends Node2D


#@onready var pathfinding = $PointsOfInterest/PathfindingLogic as PathfinderLogic

@onready var ground = $Ground as TileMap
@onready var walls = $NavigationRegion2D/Walls as TileMap
@onready var mark = $mark as TileMap
@onready var hero = $TestHero as TestHero
@onready var poic = $PointsOfInterestComponent as PointsOfInterestComponent


var astar_grid : AStarGrid2D

var pathfinding_array : Array[Node]

var points_of_interest_astar_coord: Array[Vector2i] = []

const STARTING_POINT = Vector2i(0,0)

var crossroads_path_map : Dictionary


signal points_established

signal target_update



func _ready():
	# pathfinding_array =  $PointsOfInterest.get_children().filter(func(node): return node is PathfinderLogic )
	# for node in pathfinding_array:
	# 	pass
		#node.pathfinding_init()
	
	hero.on_point_reached.connect(on_point_reached)
	
	_init_grid()
	_update_grid_from_tilemap()
	_backtrack_recursive(STARTING_POINT, [])
	poic.astar_grid = astar_grid
	hero.known_points_of_interest_astar = points_of_interest_astar_coord.duplicate()
	var points_of_interest_global = []
	for point in points_of_interest_astar_coord:
		points_of_interest_global.append(astar_grid.get_point_position(point))
	hero.known_points_of_interest_global = points_of_interest_global.duplicate()
	hero.poic = poic
	crossroads_path_map = poic.generate_path_map(Vector2i(), points_of_interest_astar_coord)
	# crossroads_path_map = poic.generate_path_map(STARTING_POINT, points_of_interest_astar_coord)
	hero.path_map = crossroads_path_map
	##--##--## ДЕБАГ
	# hero.debug_mode = true
	# hero.debug_path  = [0,0] as  Array[int]
	# hero.debug_path  = [0] as  Array[int]
	##--##--##

	points_established.emit()
	# hero.generate_path_map()
	hero._init_hero_movement()

	
	

###########################
# Настройка A* сетки для навигации
###########################

func _init_grid():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = ground.get_used_rect()
	astar_grid.cell_size = ground.tile_set.tile_size
	astar_grid.update()




func _update_grid_from_tilemap() -> void:
	for i in range(astar_grid.size.x):
		for j in range(astar_grid.size.y):
			var id = Vector2i(i, j)
			# If game_map does not have a cell source id >= 0
			# then we're looking at an invalid location
			if walls.get_cell_source_id(0, id) >= 0:
				var tile_type = walls.get_cell_tile_data(0, id).get_custom_data('is_wall')
				astar_grid.set_point_solid(id, tile_type)
				mark.set_cell(0, id, 0, Vector2(0, 0))
			# если нет земли, ставим непроходимость
			elif ground.get_cell_source_id(0,id) < 0 and astar_grid.region.has_point(id):
				astar_grid.set_point_solid(Vector2i(i, j), true)

func _check_wall(cell_pos: Vector2i) -> bool:
	if cell_pos.x <0 or cell_pos.y <0:
		return true
	return astar_grid.is_point_solid(cell_pos)
	


## TODO прокачать автосоздатель точек интереса в тупиках
func _backtrack_recursive(current_cell : Vector2i, visited: Array[Vector2i]):
	visited.append(current_cell)
	###
	# Раскраска
	#mark.set_cell(0, current_cell, 0, Vector2(0, 1))
	###
	var cell_neighbors : Array[Vector2i] = [
		Vector2i(current_cell.x +1, current_cell.y),
		Vector2i(current_cell.x, current_cell.y-1),
		Vector2i(current_cell.x-1, current_cell.y),
		Vector2i(current_cell.x, current_cell.y+1)
	]
	
	var valid_counter = 0 # Считаем валидные пути, чтобы отметить тупик
	for cell in cell_neighbors:
		if !_check_wall(cell):
			if !CustomMath.is_vector_in_array(cell,visited) :
				valid_counter +=1
				_backtrack_recursive(cell, visited)
	if valid_counter == 0:
		###
		# Раскраска
		mark.set_cell(0, current_cell, 0, Vector2(1, 0))
		###
		points_of_interest_astar_coord.append(current_cell)
	return




func set_new_point_for_hero(point_coords : Vector2i, input_hero):
	var new_point = Marker2D.new()
	new_point.position = point_coords
	add_child(new_point)
	input_hero.target = new_point
	pass




func on_point_reached() -> bool:
	return true







