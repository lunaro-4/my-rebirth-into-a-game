class_name SoulsInventory

 # TODO Души добавляются только если инициализированы, надо придумать как их инициализировать
var inventory_array : Dictionary = {Soul.SoulType.RED : 0,
							Soul.SoulType.BLUE : 0,
							Soul.SoulType.GREEN : 0}


func add(soul_type, amount: float) -> void:
	if inventory_array.keys().has(soul_type):
		inventory_array[soul_type] += amount

func spend(soul_type, amount: float) -> void:
	if amount < 0:
		amount = -amount
	if inventory_array.keys().has(soul_type):
		inventory_array[soul_type] -= amount


func get_amount() -> Dictionary:
	return inventory_array
