extends Node2D

@onready var wall_map = $Walls as TileMap

@onready var candle = $Candle as Treasure 

@onready var buttons_container = %ButtonsContainer as HBoxContainer

@onready var save_button = %SaveButton as Button

@onready var select_level_object_button = preload("res://data/ui_elements/select_level_object_button.tscn") 

var inventory = [load("res://data/level_objects/wall_dummy_object.tres"),
			load("res://data/level_objects/obstacles/door_lock.tres"),
			load("res://data/level_objects/treasures/candle.tres")] as Array[LevelObject]

var wall_blueprint = preload("res://TestingFolder/wall_blueprint.tscn")

var current_object : Node

var is_wall_selected := false

func _ready():
	for object in inventory:
		var new_button = select_level_object_button.instantiate()
		new_button.level_object = object
		new_button.button_pressed.connect(_on_button_pressed)
		buttons_container.add_child(new_button)

	save_button.pressed.connect(_save_level_to_file)
	pass

func _save_level_to_file():
	var packed_scene = PackedScene.new()
	packed_scene.pack(get_tree().get_current_scene())
	ResourceSaver.save(packed_scene,"user://savescene.tscn")
	# var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	pass



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
	var x_coord = int(floor(get_local_mouse_position().x/wall_map.tile_set.tile_size.x)*wall_map.tile_set.tile_size.x+ wall_map.tile_set.tile_size.x/2)
	var y_coord = int(floor(get_local_mouse_position().y/wall_map.tile_set.tile_size.y)*wall_map.tile_set.tile_size.y+ wall_map.tile_set.tile_size.y/2)
	var cell_to_place = Vector2i(x_coord,y_coord)
	if current_object:
		current_object.global_position = cell_to_place


func _unhandled_input(event):
	if event is InputEventMouseButton: 
		var is_placing_object = event.button_index == MOUSE_BUTTON_LEFT and event.pressed
		var is_placing_wall = event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_wall_selected
		var is_removing_wall = event.button_index == MOUSE_BUTTON_RIGHT and event.pressed
		
		var cell_to_place = wall_map.local_to_map(get_local_mouse_position())
		# print("mouse")

		if is_placing_wall:
			if !wall_map.get_cell_tile_data(0, cell_to_place):
				wall_map.set_cell(0, cell_to_place, 0, Vector2i(1,1))
		elif is_placing_object:
			# wall_map.set_cell(0, cell_to_place, 0, Vector2i(1,1))
			if current_object:
				var new_current_object_instance = current_object.duplicate()
				new_current_object_instance.modulate.a = 1
				add_child(new_current_object_instance)
				pass
		if is_removing_wall:
			if wall_map.get_cell_tile_data(0, cell_to_place):
				wall_map.erase_cell(0,cell_to_place)


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

