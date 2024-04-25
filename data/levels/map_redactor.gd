class_name MapRedactor extends Node2D

@export var wall_map : TileMap


@onready var select_level_object_button = preload("res://data/ui_elements/select_level_object_button.tscn") 

# @export var inventory = [] as Array

@export var wall_blueprint: PackedScene #  = preload("res://TestingFolder/wall_blueprint.tscn")

@export var buttons_container : HBoxContainer

var cell_to_place

var current_object : Node

var occupied_cells = {} as Dictionary

var is_wall_selected := false

var is_in_redacting_mode := true

const DEFAULT_SAVE_RESOURCE_PATH = "user://save_res.tres"

func _ready():
	pass

func populate_buttons_container(inventory):
	for object in inventory:
		var new_button = select_level_object_button.instantiate()
		new_button.level_object = object
		new_button.button_pressed.connect(_on_button_pressed)
		buttons_container.add_child(new_button)

func save_level_to_file(save_path: String = DEFAULT_SAVE_RESOURCE_PATH) -> void:
	var save_file = SaveFile.new()
	save_file.occupied_cells = occupied_cells
	save_file.wall_tiles_used_array = wall_map.get_used_cells(0)
	for node in get_tree().get_nodes_in_group("Savable"):
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		var node_data = node.call("save")
		save_file.node_data_array.append(node_data)
	ResourceSaver.save(save_file,save_path)
	pass
	return

func _play_init():
	save_level_to_file()
	get_tree().change_scene_to_file("res://TestingFolder/testing_play_from_redactor.tscn")


func reset_map():
	wall_map.clear()
	for node in get_tree().get_nodes_in_group("Savable"):
		node.queue_free()


func load_level_from_file(level_res_path : String = DEFAULT_SAVE_RESOURCE_PATH):
	var load_res = load(level_res_path) as SaveFile
	reset_map()
	occupied_cells = load_res.occupied_cells
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

func _on_button_pressed(object:LevelObject):
	if object.type == LevelObject.ObjectType.WALL:
		object.object_scene = wall_blueprint
		is_wall_selected = true
	else:
		is_wall_selected = false
	if object.scale == 0:
		_swap_chosen_object(object.object_scene)
	else:
		_swap_chosen_object(object.object_scene, object.scale)
	pass

func _process(_delta):
	#warning-ignore:integer_division
	var x_coord = int(float(get_local_mouse_position().x)/float(wall_map.tile_set.tile_size.x)*float(wall_map.tile_set.tile_size.x)+ float(wall_map.tile_set.tile_size.x)/2)
	#warning-ignore:integer_division
	var y_coord = int(float(get_local_mouse_position().y)/wall_map.tile_set.tile_size.y*wall_map.tile_set.tile_size.y+ float(wall_map.tile_set.tile_size.y)/2)
	cell_to_place = Vector2i(x_coord,y_coord)
	if current_object:
		current_object.global_position = cell_to_place


func _unhandled_input(event):
	if is_in_redacting_mode:
		if event is InputEventMouseButton: 
			var is_placing_object = event.button_index == MOUSE_BUTTON_LEFT and event.pressed
			var is_placing_wall = event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_wall_selected
			var is_removing_wall = event.button_index == MOUSE_BUTTON_RIGHT and event.pressed
			
			var map_cell_to_place = wall_map.local_to_map(get_local_mouse_position())
			# print("mouse")

			if is_placing_wall:
				if !wall_map.get_cell_tile_data(0, map_cell_to_place):
					wall_map.set_cell(0, map_cell_to_place, 0, Vector2i(1,1))
			elif is_placing_object:
				# wall_map.set_cell(0, cell_to_place, 0, Vector2i(1,1))
				if current_object and occupied_cells.keys().filter(func(cell): return CustomMath.compare_vectors(cell, Vector2i(current_object.global_position))).size() == 0:
					var new_current_object_instance = current_object.duplicate()
					new_current_object_instance.modulate.a = 1
					new_current_object_instance.add_to_group("Savable")
					occupied_cells[Vector2i(new_current_object_instance.global_position)] = new_current_object_instance
					add_child(new_current_object_instance)
					pass
			if is_removing_wall:
				if occupied_cells.keys().filter(func(cell): return CustomMath.compare_vectors(cell, Vector2i(cell_to_place))).size() > 0:
					occupied_cells[CustomMath.find_in_array_i(cell_to_place, occupied_cells.keys() as Array[Vector2i])].queue_free()				
					occupied_cells.erase(CustomMath.find_in_array_i(cell_to_place, occupied_cells.keys() as Array[Vector2i]))
				if wall_map.get_cell_tile_data(0, map_cell_to_place):
					wall_map.erase_cell(0, map_cell_to_place)


func _clear_current_object():
	if current_object:
		current_object.queue_free()
	
func _swap_chosen_object(new_object: PackedScene, object_scale : float = 1): 
	_clear_current_object()
	var new_object_instance = new_object.instantiate()	
	new_object_instance.scale = Vector2(object_scale, object_scale)
	new_object_instance.modulate.a = 0.4
	current_object = new_object_instance
	add_child(current_object)

