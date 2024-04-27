extends Node

signal soul_amount_updated
signal inventory_updated

const SAVE_FILE_LOCATION = "user://player_save/save.sav"

var objects_inventory = LevelObjectsInventory.new()
var soul_inventory = SoulsInventory.new()

 
func _ready():
	soul_inventory.add(0, 12)
	soul_inventory.add(1, 12)
	soul_inventory.add(2, 12)

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
	for object in json_object_array_data:
		var new_object = LevelObject.new()
		new_object.name = object.name
		new_object.object_scene = load(object.object_scene)
		new_object.icon = load(object.icon)
		new_object.type = object.type
		new_object.scale = object.scale
		new_object.recepie = [] as Array[Soul] 
		for soul in object.recepie:
			new_object.recepie.append(load(soul))
		new_object_array.append(new_object)

	### Парсим души
	objects_inventory.set_new_array(new_object_array)
	var json_soul_string = save_file.get_line()
	json = JSON.new()
	parse_result = json.parse(json_soul_string)
	if not parse_result == OK:
		printerr("JSON Parse Error: ", json.get_error_message(),
		" in ", json_object_string, " at line ", json.get_error_line())
		return false
	var json_soul_data = json.get_data()
	soul_inventory.set_new_array(json_soul_data)

	return true

func save_player_state():
	if !DirAccess.dir_exists_absolute("user://player_save"):
		DirAccess.make_dir_absolute("user://player_save")
	var save_file = FileAccess.open(SAVE_FILE_LOCATION, FileAccess.WRITE)
	var object_save_array = []
	for object in objects_inventory.get_inventory():
		object_save_array.append(object.call("save"))
	var json_object_string = JSON.stringify(object_save_array)
	save_file.store_line(json_object_string)
	var json_soul_string = JSON.stringify(soul_inventory.get_amount())
	save_file.store_line(json_soul_string)


func add_object_to_inventory(object):
	objects_inventory.append(object)
	print(objects_inventory.get_inventory())
	inventory_updated.emit()

func change_soul_amount(change_values : Dictionary) -> bool:
	for value in change_values.keys():
		if !soul_inventory.add(value, change_values [value]):
			printerr("Something went wrong with changing value: ",
			value, " in ", soul_inventory.get_amount(), " for ", change_values [value])
			return false
	soul_amount_updated.emit()
	return true


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
	print(soul_inventory.get_amount())
	return true
 

func get_souls():
	return soul_inventory.get_amount()

func get_inventory():
	return objects_inventory.get_inventory()
