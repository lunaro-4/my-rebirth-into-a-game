extends Node2D


@onready var pathfinding = $PointsOfInterest/PathfindingLogic as PathfinderLogic

@onready var ground = $Ground as TileMap
@onready var walls = $NavigationRegion2D/Walls as TileMap
@onready var mark = $mark as TileMap

var astar_grid : AStarGrid2D

var pathfinding_array : Array[Node]

var points_of_interest: Array[Vector2i] = []



func _ready():
	pathfinding_array =  $PointsOfInterest.get_children().filter(func(node): return node is PathfinderLogic )
	for node in pathfinding_array:
		pass
		#node.pathfinding_init()
	 
	_init_grid()
	_update_grid_from_tilemap()
	_backtrack_recursive(Vector2i(0,0), [])
	

func _init_grid():
	astar_grid = AStarGrid2D.new()
	astar_grid.size = ground.get_used_rect().size
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
			elif ground.get_cell_source_id(0,id) < 0:
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
			if !CustomMath.find_in_array(cell,visited) :
				valid_counter +=1
				_backtrack_recursive(cell, visited)
	if valid_counter == 0:
		###
		# Раскраска
		mark.set_cell(0, current_cell, 0, Vector2(1, 0))
		###
		points_of_interest.append(current_cell)
	return
































