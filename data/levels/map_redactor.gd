class_name MapRedactor extends Node2D


@export var wall_map : TileMap
# @export var inventory = [] as Array
@export var wall_blueprint: LevelObject #  = preload("res://TestingFolder/wall_blueprint.tscn")
@export var buttons_container : HBoxContainer

var cell_to_place
var current_object : LevelObject
var current_object_scene : Node2D
var current_object_button : Control
var occupied_cells = {} as Dictionary
var is_wall_selected := false
var is_in_redacting_mode := true
var placed_objects_array = []
var left_objects_array = []
var object_instance_dict = {}

@onready var select_level_object_button = preload("res://data/ui_elements/select_level_object_button.tscn") 


func _ready():
	pass

func _process(_delta):
	var tile_size_x = float(wall_map.tile_set.tile_size.x)
	var tile_size_y = float(wall_map.tile_set.tile_size.y)
	var mouse_pos = get_local_mouse_position()
	var x_coord = floor(mouse_pos.x/tile_size_x)*tile_size_x + tile_size_x/2
	var y_coord = floor(mouse_pos.y/tile_size_y)*tile_size_y + tile_size_y/2
	cell_to_place = Vector2i(x_coord,y_coord)
	if current_object_scene:
		current_object_scene.global_position = cell_to_place

func _unhandled_input(event):
	if is_in_redacting_mode:
		if event is InputEventMouseButton: 
			var is_placing_object = event.button_index == MOUSE_BUTTON_LEFT and event.pressed
			var is_placing_wall = event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_wall_selected
			var is_removing_wall = event.button_index == MOUSE_BUTTON_RIGHT and event.pressed
			
			# var map_cell_to_place = wall_map.local_to_map(get_local_mouse_position())
			# print("mouse")

			if is_placing_wall:
				_set_wall(cell_to_place, true)

			elif is_placing_object:
				# wall_map.set_cell(0, cell_to_place, 0, Vector2i(1,1))
				if current_object_scene and occupied_cells.keys().filter(func(cell):
					return CustomMath.compare_vectors(cell,
				Vector2i(current_object_scene.global_position))).size() == 0:
					_clear_current_object_scene()
					left_objects_array.erase(current_object)
					placed_objects_array.append(current_object)
					_populate_buttons_container(left_objects_array)
					var new_current_object_instance = _get_scene_from_object(current_object)
					new_current_object_instance.position= cell_to_place
					new_current_object_instance.modulate.a = 1
					new_current_object_instance.add_to_group("Savable")
					occupied_cells[Vector2i(new_current_object_instance.global_position)] = current_object
					object_instance_dict [current_object] = new_current_object_instance
					add_child(new_current_object_instance)
					current_object = null
					pass

			if is_removing_wall:
				_remove_object_scene_by_coord(cell_to_place)
				_set_wall(cell_to_place, false)

func _set_wall(local_coord : Vector2i, set_value : bool):
	var map_coord = wall_map.local_to_map(local_coord)
	var is_cell_occupied = (wall_map.get_cell_tile_data(0, map_coord)) or (local_coord in occupied_cells.keys())
	if set_value and !is_cell_occupied:
		wall_map.set_cell(0, map_coord, 0, Vector2i(1,1))
		occupied_cells [local_coord] = null
	elif !set_value and is_cell_occupied:
		wall_map.erase_cell(0, map_coord)
		occupied_cells.erase(local_coord)
	else:
		# printerr("set_value and is_cell_occupied are equal!")
		pass

func _remove_object_scene_by_coord(coord : Vector2i):
	if occupied_cells.keys().filter(func(cell): return CustomMath.compare_vectors(cell, coord)).size() > 0:
		var coordinate_key = CustomMath.find_in_array_i(cell_to_place, occupied_cells.keys() as Array[Vector2i])
		if occupied_cells [coordinate_key] != null:
			_remove_object_scene_by_object(occupied_cells [coordinate_key])

func _remove_object_scene_by_object(object_to_remove : LevelObject, repopulate_buttons : bool = true):
	object_instance_dict [object_to_remove] .queue_free()
	object_instance_dict.erase(object_to_remove)
	placed_objects_array.erase(object_to_remove)	
	left_objects_array.append(object_to_remove)
	if repopulate_buttons:
		_populate_buttons_container(left_objects_array)
	# object_instance_dict [object_to_remove]

# TODO сделать такую же фильтрацию при загрузке сейва карты
func update_inventory(inventory):
	for object in placed_objects_array:
		var input_array_fixed = inventory.filter(func(compare_object : LevelObject): return compare_object.is_equal_to(object))
		if input_array_fixed.size() > 0:
			inventory.erase(input_array_fixed[0])
		else:
			_remove_object_scene_by_object(object, false)

	left_objects_array = inventory
	_populate_buttons_container(left_objects_array)

###########################
# Обработка кнопок
###########################

func _populate_buttons_container(_inventory):
	var inventory = _inventory.duplicate()
	for child in buttons_container.get_children():
		child.queue_free()
	if wall_blueprint:
		inventory.push_front(wall_blueprint)
	for object in inventory:
		var new_button = select_level_object_button.instantiate()
		new_button.level_object = object
		new_button.button_pressed.connect(_on_button_pressed)
		buttons_container.add_child(new_button)


func _clear_current_object_scene():
	if current_object_scene:
		current_object_scene.queue_free()
		current_object_scene = null


func _on_button_pressed(object:LevelObject):
	if object.type == LevelObject.ObjectType.WALL:
		object.object_scene = wall_blueprint.object_scene
		is_wall_selected = true
		_swap_chosen_object(object, object.object_scene.instantiate())
	else:
		is_wall_selected = false
		_swap_chosen_object(object)
	current_object = object


func _get_scene_from_object(object: LevelObject) -> Node2D:
	var object_scale
	if object.scale == 0:
		object_scale = 1
	else:
		object_scale = object.scale
	var new_object_instance = object.get_scene_instance()
	new_object_instance.scale = Vector2(object_scale, object_scale)
	return new_object_instance

	
func _swap_chosen_object(object: LevelObject, preset_scene : Node2D = null): 
	_clear_current_object_scene()
	if preset_scene == null:
		current_object_scene = _get_scene_from_object(object)
	else:
		current_object_scene = preset_scene
	current_object_scene.modulate.a = 0.4
	add_child(current_object_scene)


###########################
# Save/Load/Reset
###########################

const DEFAULT_SAVE_RESOURCE_PATH = "user://save_res.tres"


func save_level_to_file(save_path: String = DEFAULT_SAVE_RESOURCE_PATH) -> void:
	printerr("ВНИМАНИЕ: эта функция ещё не обновлялась и работает некорректно с инвентарем")
	var save_file = SaveFile.new()
	for node in get_tree().get_nodes_in_group("Savable"):
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		save_file.occupied_cells [Vector2i(node.position)] = node.bound_object
	for coord in occupied_cells.keys():
		if occupied_cells [coord] == null:
			save_file.occupied_cells [coord] = null


	ResourceSaver.save(save_file,save_path)

func reset_map():
	wall_map.clear()
	occupied_cells = {}
	for node in get_tree().get_nodes_in_group("Savable"):
		node.queue_free()

func load_level_from_file(level_res_path : String = DEFAULT_SAVE_RESOURCE_PATH):
	printerr("ВНИМАНИЕ: эта функция ещё не обновлялась и работает некорректно с инвентарем")
	var load_res = load(level_res_path) as SaveFile
	reset_map()
	# print(occupied_cells.values()[0])
	# print(type_string(typeof(occupied_cells.values()[0])))
	occupied_cells = {}
	var local_occupied_cells = load_res.occupied_cells
	for coord in local_occupied_cells.keys():
		var new_level_object = local_occupied_cells [coord]
		if new_level_object != null:
			var new_object_scene = _get_scene_from_object(new_level_object)
			new_object_scene.position = coord
			new_object_scene.add_to_group("Savable")
			add_child(new_object_scene)
			occupied_cells [ coord ] = new_level_object
		else:
			_set_wall(Vector2i(coord), true)
			occupied_cells [coord] = null
