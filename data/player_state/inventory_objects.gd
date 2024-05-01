class_name LevelObjectsInventory

var inventory_array : Array[LevelObject] = []


func append(object: LevelObject) -> void:
	inventory_array.append(object)

func remove(object: LevelObject) -> void:
	inventory_array.erase(object)


func get_inventory() -> Array[LevelObject]:
	return inventory_array

func get_category(category) -> Array[LevelObject]:
	var fixed_array = inventory_array.duplicate()
	return fixed_array.filter(func(object: LevelObject): return object.type == category)

func get_count() -> Dictionary:
	var count_dict : Dictionary = {}
	for object in inventory_array:
		if count_dict.keys().has(object):
			count_dict[object] += 1
		else:
			count_dict[object] = 1
	return count_dict

func set_new_array(array: Array) -> Array[LevelObject]:
	inventory_array = array as Array[LevelObject]
	return inventory_array

func replace_object(index : int, new_object : LevelObject):
	if inventory_array.size() <= index:
		return false
	else:
		inventory_array [index] = new_object
	return true
