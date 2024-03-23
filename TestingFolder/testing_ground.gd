extends Node2D


@onready var pathfinding = $PointsOfInterest/PathfindingLogic as PathfinderLogic

@onready var ground = $Ground as TileMap
@onready var walls = $NavigationRegion2D/Walls as TileMap
@onready var mark = $mark as TileMap

var astar_grid : AStarGrid2D

var pathfinding_array : Array[Node]

var count_iter: int = 0

## TODO внедрить А*, создать автосоздатель точек интереса в тупиках

# Called when the node enters the scene tree for the first time.
func _ready():
	pathfinding_array =  $PointsOfInterest.get_children().filter(func(node): return node is PathfinderLogic )
	for node in pathfinding_array:
		pass
		#node.pathfinding_init()
	 
	_init_grid()
	_update_grid_from_tilemap()
	#_bactrack_recursive([], Vector2i(0,0), [])
	

func _init_grid():
	astar_grid = AStarGrid2D.new()
	astar_grid.size = ground.get_used_rect().size
	astar_grid.cell_size = ground.tile_set.tile_size
	astar_grid.update()





func _update_grid_from_tilemap() -> void:
	for i in range(astar_grid.size.x):
		for j in range(astar_grid.size.y):
			var id = Vector2i(i, j)
			#astar_grid.set_point_solid(id, false)
			# If game_map does not have a cell source id >= 0
			# then we're looking at an invalid location
			if walls.get_cell_source_id(0, id) >= 0:
				var tile_type = walls.get_cell_tile_data(0, id).get_custom_data('is_wall')
				astar_grid.set_point_solid(id, tile_type)
				mark.set_cell(0, id, 0, Vector2(0, 0))
				#print(id)
			# If looking at a location outside of the game map,
			# default to marking the cell solid so the player can't navigate
			# outside of the game map.
			# Shouldn't be an issue in this demo since grid size comes from map size
			# but something to keep in mind.
			#else:
				#astar_grid.set_point_solid(Vector2i(i, j), true)

func check_wall(cell_pos: Vector2i) -> bool:
	if cell_pos.x <0 or cell_pos.y <0:
		#print(0)
		return true
	#print("is_solid ",astar_grid.is_point_solid(cell_pos) )
	return astar_grid.is_point_solid(cell_pos)
	

func _bactrack_recursive(rolling_stack : Array[Vector2i],
 current_cell : Vector2i, visited: Array[Vector2i]):
	count_iter +=1
	if count_iter %100 ==0:
		pass
	rolling_stack.append(current_cell)
	visited.append(current_cell)
	mark.set_cell(0, current_cell, 0, Vector2(0, 1))
	var cell_neighbors : Array[Vector2i] = [
		Vector2i(current_cell.x +1, current_cell.y),
		Vector2i(current_cell.x, current_cell.y-1),
		Vector2i(current_cell.x-1, current_cell.y),
		Vector2i(current_cell.x, current_cell.y+1)
	]
	var valid_neighbors : Array[Vector2i] = []
	
	#for i in cell_neighbors:
		#if _find_in_array(i, rolling_stack):
			#unvalid_neighbors.append(i)
	for i in cell_neighbors:
		#print(i)
		if !check_wall(i): 
			#print("first check passed")
			#print(_check_wall(i))
			if !CustomMath.find_in_array(i,visited) and CustomMath.find_in_array(i, rolling_stack):
				valid_neighbors.append(i)
				
				
	print(current_cell, ",")
	if valid_neighbors.size() <=0:
		mark.set_cell(0, current_cell, 0, Vector2(1, 0))
		return
	
	for cell in valid_neighbors:
		var next_cell_to_go = cell
		_bactrack_recursive(rolling_stack,next_cell_to_go, visited)
	rolling_stack.pop_back()
	return
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	pass


class Cell:
	var x :int
	var y: int
	var unavailable : bool
	
	func _init(vect: Vector2i, _unavailable = false):
		x = vect.x
		y = vect.y
		unavailable = _unavailable

































