class_name CustomMath


static func compare_vectors(first : Vector2i, second : Vector2i) -> bool:
	if first.x == second.x and first.y == second.y:
		return true
	else:
		return false

static func find_in_array(vec: Vector2, arr :Array) -> Vector2:
	for i in arr:
		if compare_vectors(i,vec):
			return i
	return Vector2()

static func find_in_array_i(vec: Vector2i, arr :Array[Vector2i]) -> Vector2i:
	for i in arr:
		if compare_vectors(i,vec):
			return i
	return Vector2i()

static func is_vector_in_array(vec: Vector2, arr :Array) -> bool:
	for i in arr:
		if compare_vectors(i,vec):
			return true
	return false

static func get_uniqe_tail_array_vector(arr1,arr2):
	var arr1_tail = arr1.duplicate()
	var arr2_tail = arr2.duplicate()
	for point in range(arr1.size()):
		if point != arr2.size()-1:
			if !CustomMath.compare_vectors(arr1[point], arr2[point]):
				arr1_tail = arr1.slice(point)
				arr2_tail = arr2.slice(point)
				break
		else:

			arr1_tail = []
			arr2_tail = []
	return [arr1_tail,arr2_tail]
