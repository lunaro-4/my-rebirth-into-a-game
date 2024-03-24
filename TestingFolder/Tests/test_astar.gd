extends GutTest

var vec1= Vector2i(0,0)
var vec2= Vector2i(0,0)
var vec3= Vector2i(3,12)
var vec4= Vector2i(3,12)
var vec5= Vector2i(7,92)

func test_array_compare_vectors():
	assert_true(CustomMath.compare_vectors(vec1, vec2))
	
	assert_true(CustomMath.compare_vectors(vec3,vec4))
	
	assert_false(CustomMath.compare_vectors(vec3,vec5))

func test_array_find_vector_1():
	var arr1: Array[Vector2i] = [vec1,vec2,vec3,vec4,vec5]
	var arr2: Array[Vector2i] = [vec1,vec2,vec3,vec4,vec5]
	
	for vec in arr1:
		assert_true(CustomMath.find_in_array(vec, arr2))

func test_array_find_vector_2():
	var arr1: Array[Vector2i] = [Vector2i(0,0), Vector2i(5,14),
	 Vector2i(0,9), Vector2i(4,16),
	 Vector2i(2,1), Vector2i(4,1),
	 Vector2i(54,2)]
	
	assert_true(CustomMath.find_in_array(Vector2(0,0),arr1))
	assert_true(CustomMath.find_in_array(Vector2(0,9),arr1))
	assert_true(CustomMath.find_in_array(Vector2(4,1),arr1))
	assert_false(CustomMath.find_in_array(Vector2(7,12),arr1))

