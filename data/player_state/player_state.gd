extends Node

signal soul_amount_updated
signal inventory_updated
signal treasures_updated

const SAVE_FILE_LOCATION = "user://player_save/save.sav"

var objects_inventory = LevelObjectsInventory.new()
var soul_inventory = SoulsInventory.new()
var treasure_inventory = LevelObjectsInventory.new()

var known_souls = [
	load("res://data/souls_and_currency/red_soul.tres"),
	load("res://data/souls_and_currency/green_soul.tres"),
	load("res://data/souls_and_currency/blue_soul.tres")
] as Array[Soul]
 
func _ready():
	_debug_stats()

func _debug_stats():
	soul_inventory.add(0, 12)
	soul_inventory.add(1, 12)
	soul_inventory.add(2, 12)
	var new_treasure = load("res://data/level_objects/treasures/candle.tres")
	new_treasure.treasure_soul_intake = {
		known_souls [0] : 5,
		known_souls [1] : 2,
		known_souls [2] : 0
	}
	treasure_inventory.append(new_treasure)

func load_player_state() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_LOCATION):
		return false
	var save_file = FileAccess.open(SAVE_FILE_LOCATION, FileAccess.READ)

	### Парсим объекты
	var json_object_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_object_string)
	if not parse_result == OK:
		printerr("JSON Parse Error: ", json.get_error_message(),
		" in ", json_object_string, " at line ", json.get_error_line())
		return false
	var json_object_array_data = json.get_data()	
	var new_object_array = [] as Array[LevelObject]
	var new_treasure_array = [] as Array[LevelObject]
	for object in json_object_array_data:
		var new_object = LevelObject.new()
		new_object.name = object.name
		new_object.object_scene = load(object.object_scene)
		# new_object.object_scene = object.object_scene
		new_object.icon = load(object.icon)
		# new_object.icon = object.icon
		new_object.type = object.type
		new_object.scale = object.scale
		new_object.recepie = [] as Array[Soul] 
		new_object.treasure_soul_intake = {} as Dictionary
		for soul in object.recepie:
			new_object.recepie.append(load(soul))
		for soul in object.treasure_soul_intake.keys():
			var soul_object = load(soul)
			new_object.treasure_soul_intake [soul_object] = object.treasure_soul_intake [soul] 
		if new_object.type == LevelObject.ObjectType.TREASURE:
			new_treasure_array.append(new_object)
		else:
			new_object_array.append(new_object)
	objects_inventory.set_new_array(new_object_array)
	treasure_inventory.set_new_array(new_treasure_array)

	inventory_updated.emit()
	treasures_updated.emit()

	### Парсим души
	var json_soul_string = save_file.get_line()
	json = JSON.new()
	parse_result = json.parse(json_soul_string)
	if not parse_result == OK:
		printerr("JSON Parse Error: ", json.get_error_message(),
		" in ", json_object_string, " at line ", json.get_error_line())
		return false
	var json_soul_data = json.get_data()
	soul_inventory.set_new_array(json_soul_data)

	soul_amount_updated.emit()

	return true

func save_player_state():
	if !DirAccess.dir_exists_absolute("user://player_save"):
		DirAccess.make_dir_absolute("user://player_save")
	var save_file = FileAccess.open(SAVE_FILE_LOCATION, FileAccess.WRITE)
	var object_save_array = []
	for object in objects_inventory.get_inventory():
		object_save_array.append(object.call("save"))
	for treasure in treasure_inventory.get_inventory():
		object_save_array.append(treasure.call("save"))
	var json_object_string = JSON.stringify(object_save_array)
	save_file.store_line(json_object_string)
	var json_soul_string = JSON.stringify(soul_inventory.get_amount())
	save_file.store_line(json_soul_string)


func add_object_to_inventory(object):
	objects_inventory.append(object)
	# print(objects_inventory.get_inventory())
	inventory_updated.emit()

## change_values = {Soul.type : amount} 
func change_soul_amount(change_values : Dictionary) -> bool:
	for value in change_values.keys():
		if !soul_inventory.add(value, change_values [value]):
			printerr("Something went wrong with changing value: ",
			value, " in ", soul_inventory.get_amount(), " for ", change_values [value])
			return false
	soul_amount_updated.emit()
	return true


## change_values = {Soul.type : amount} 
func spend_souls(change_values : Dictionary) -> bool:
	for value in change_values.keys():
		var change_values_return_code = soul_inventory.spend(value, change_values [value])
		if change_values_return_code != soul_inventory.ErrorCodes.OK: 
			if change_values_return_code == soul_inventory.ErrorCodes.NO_SUCH_SOUL:
				printerr("Can't find ", value, " in ", soul_inventory.get_amount())
				return false
			if change_values_return_code == soul_inventory.ErrorCodes.LESS_THAN_ZERO:
				assert(false, str("Attempt to set value ", value, " below zero"))
	soul_amount_updated.emit()
	return true
 

func get_souls():
	return soul_inventory.get_amount()

func get_inventory():
	return objects_inventory.get_inventory()

func get_available_souls():
	var available_souls = [
		load("res://data/souls_and_currency/red_soul.tres"),
		load("res://data/souls_and_currency/blue_soul.tres"),
		load("res://data/souls_and_currency/green_soul.tres")
	] as Array[Soul]
	available_souls.sort_custom(func(soul1, soul2): return soul1.type < soul2.type)
	return available_souls

func get_treasures():
	return treasure_inventory.get_inventory()

func update_treasure(old_treasure_index : int, new_treasure : LevelObject):
	var is_replacement_succes = treasure_inventory.replace_object(old_treasure_index , new_treasure)
	if is_replacement_succes:
		return true
	else:
		printerr("Something went wrong while replacing object ",
		old_treasure_index, " to ", new_treasure,
		" in ", treasure_inventory.get_inventory())
	pass
