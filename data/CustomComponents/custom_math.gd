class_name CustomMath


static func compare_vectors(first : Vector2i, second : Vector2i) -> bool:
	if first.x == second.x and first.y == second.y:
		return true
	else:
		return false

static func find_in_array(vec: Vector2i, arr :Array[Vector2i]) -> bool:
	for i in arr:
		if compare_vectors(i,vec):
			return true
	return false
