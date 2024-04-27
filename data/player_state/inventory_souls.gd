class_name SoulsInventory

enum ErrorCodes {
	OK = 0,
	NO_SUCH_SOUL = 1,
	LESS_THAN_ZERO = 2
}

 # TODO Души добавляются только если инициализированы, надо придумать как их инициализировать
var inventory_array : Dictionary = {Soul.SoulType.RED : 0,
							Soul.SoulType.BLUE : 0,
							Soul.SoulType.GREEN : 0}


func add(soul_type : int , amount: float) -> bool:
	if inventory_array.keys().has(soul_type):
		if inventory_array[soul_type] + amount <0:
			return false
		inventory_array[soul_type] += amount
		return true
	return false

func spend(soul_type : int , amount: float) -> int:
	if amount < 0:
		amount = -amount
	if inventory_array.keys().has(soul_type):
		if inventory_array[soul_type] - amount <0:
			return ErrorCodes.LESS_THAN_ZERO
		else:
			inventory_array[soul_type] -= amount
			return ErrorCodes.OK
	else:
		return ErrorCodes.NO_SUCH_SOUL


func get_amount() -> Dictionary:
	return inventory_array

func set_new_array(array: Dictionary) ->Dictionary:
	var new_array = {}
	for key in array.keys():
		new_array [int(key)] = array [key]
	inventory_array = new_array
	return inventory_array
