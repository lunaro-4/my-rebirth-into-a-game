class_name Level extends Node2D




enum states {
	REDACTING,
	}

var save_location = "user://level1/save.tres"
var player_inventory #= [load("res://data/level_objects/wall_dummy_object.tres"),
# 			load("res://data/level_objects/obstacles/door_lock.tres"),
# 			load("res://data/level_objects/treasures/candle.tres")]
var wall_dummy_object = load("res://data/level_objects/wall_dummy_object.tres")

@onready var buttons_container = %ButtonsContainer as HBoxContainer
@onready var map_redactor_component = $MapRedactorComponent as MapRedactor
@onready var save_button = %SaveButton as Button
@onready var load_button = %LoadButton as Button
@onready var reset_button = %ResetButton as Button
@onready var play_button = %PlayButton as Button
@onready var crafting_menu_toggle = %CraftingMenuToggle as Button

func _ready():

	map_redactor_component.wall_blueprint = wall_dummy_object
	_update_inventory()

	map_redactor_component.wall_map = wall_map
	
	save_button.pressed.connect(map_redactor_component.save_level_to_file.bind(save_location))
	load_button.pressed.connect(map_redactor_component.load_level_from_file.bind(save_location))
	reset_button.pressed.connect(map_redactor_component.reset_map)
	play_button.pressed.connect(start_game)
	crafting_menu_toggle.pressed.connect(_inventory_visibility_toggle)

	
	PlayerState.inventory_updated.connect(_update_inventory)
	_swich_interfaces(true)


func _update_inventory():
	player_inventory = PlayerState.get_inventory().duplicate()
	# player_inventory.push_front(wall_dummy_object)
	map_redactor_component.update_inventory(player_inventory)

func _swich_interfaces(state):
	$MenuButtons.visible = state
	$ObjectSelectionBarLayer.visible = state

func _inventory_visibility_toggle():
	%InventoryUI.visible = !%InventoryUI.visible

###########################
# Начало игры
###########################

signal points_established
signal target_update

const STARTING_POINT = Vector2i(0,0)
const DEFAULT_SAVE_RESOURCE_PATH = "user://save_res.tres"

var astar_grid : AStarGrid2D
var pathfinding_array : Array[Node]
var points_of_interest_astar_coord: Array[Vector2i] = []
var points_of_interest_global = []
var crossroads_path_map : Dictionary

@onready var ground = $Floor as TileMap
@onready var wall_unbreakable = $NavigationRegion2D/WallUnbreakable as TileMap
@onready var debug_mark = $mark as TileMap
@onready var poic = $PointsOfInterestComponent as PointsOfInterestComponent
@onready var wall_map = %Walls as TileMap


func start_game():

	map_redactor_component.is_in_redacting_mode = false

	map_redactor_component.save_level_to_file()

	_swich_interfaces(false)

	$NavigationRegion2D.bake_navigation_polygon()

	_init_grid()
	_update_grid_from_tilemap(wall_unbreakable)
	_update_grid_from_tilemap(wall_map)
	_backtrack_recursive(STARTING_POINT, [])

	poic.astar_grid = astar_grid
	for point in points_of_interest_astar_coord:
		points_of_interest_global.append(astar_grid.get_point_position(point))

	points_established.emit()

	var hero = spawn_hero(Vector2i(1,1))#, [2,1,0,1] as Array[int])
	$StateChartDebugger.debug_node(hero.get_node("StateChart"))

	
	

###########################
# Настройка A* сетки для навигации
###########################

func _init_grid():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = wall_unbreakable.get_used_rect()
	astar_grid.cell_size = wall_unbreakable.tile_set.tile_size
	astar_grid.update()
	return astar_grid





func _update_grid_from_tilemap(solid_tilemap) -> void:
	for i in range(astar_grid.region.position.x, astar_grid.region.end.x):
		for j in range(astar_grid.region.position.y, astar_grid.region.end.y):
			var id = Vector2i(i, j)
			# If game_map does not have a cell source id >= 0
			# then we're looking at an invalid location
			if solid_tilemap.get_cell_source_id(0, id) >= 0:
				var tile_type = solid_tilemap.get_cell_tile_data(0, id).get_custom_data('is_wall')
				astar_grid.set_point_solid(id, tile_type)
				debug_mark.set_cell(0, id, 0, Vector2(0, 0))
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
	#debug_mark.set_cell(0, current_cell, 0, Vector2(0, 1))
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
		debug_mark.set_cell(0, current_cell, 0, Vector2(1, 0))
		###
		points_of_interest_astar_coord.append(current_cell)
	return





###########################
# Базовая обработка героя
###########################

const MAX_HERO_POINTS_ON_MAP = 8

var hero_points  = [] as Array[Marker2D]

func set_new_point_for_hero(point_coords : Vector2i, input_hero):
	var new_point = Marker2D.new()
	new_point.position = point_coords
	add_child(new_point)
	hero_points.append(new_point)
	input_hero.exploration_target = new_point
	if hero_points.size() > MAX_HERO_POINTS_ON_MAP:
		hero_points.pop_front().queue_free()




func on_point_reached() -> bool:
	return true




# var hero_scene = load("res://data/heroes/test_hero/test_hero.tscn")
var hero_scene = load("res://data/heroes/rogue/rogue.tscn")
# var hero_scene = load("res://data/heroes/rogue/rogue.tscn")

func spawn_hero(spawn_point_astar, debug_path = null ):
	var hero = hero_scene.instantiate()
	if debug_path != null:
		hero.debug_mode = true
		hero.debug_path = debug_path
	hero.starting_point_astar = spawn_point_astar
	hero.scale = Vector2(0.2,0.2)
	hero.global_position = astar_grid.get_point_position(spawn_point_astar)	
	hero.on_point_reached.connect(on_point_reached)
	hero.known_points_of_interest_astar = points_of_interest_astar_coord.duplicate()
	hero.known_points_of_interest_global = points_of_interest_global.duplicate()
	hero.poic = poic
	crossroads_path_map = poic.generate_path_map(hero.starting_point_astar, points_of_interest_astar_coord)
	# print(crossroads_path_map)
	# DebugTools.beautiful_dict_print(crossroads_path_map)
	hero.path_map = crossroads_path_map
	add_child(hero)
	hero._init_hero_movement()
	return hero

func global_to_astar(input_pos: Vector2):
	return Vector2i(floor(input_pos.x/astar_grid.cell_size.x), floor(input_pos.y/astar_grid.cell_size.y))



func _reset_map():
	wall_map.clear()
	for node in get_tree().get_nodes_in_group("Savable"):
		node.queue_free()

func _load_level_from_file(level_res_path : String = DEFAULT_SAVE_RESOURCE_PATH):
	var load_res = load(level_res_path) as SaveFile
	_reset_map()
	# wall_map.tile_set = load_res.wall_tile_set.duplicate()
	for tile in load_res.wall_tiles_used_array:
		wall_map.set_cell(0, tile, 0, Vector2i(1,1))
	for node_data in load_res.node_data_array:
		var new_object = load(node_data['filename']).instantiate()
		new_object.add_to_group("Savable")
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])

