class_name PointsOfInterestComponent extends Node2D



# @export var STARTING_POINT : Vector2i

var astar_grid : AStarGrid2D

signal map_ready 


func _generate_rogue_path(point: int,array_to_inspect) -> Dictionary:
	var rogue_paths = {}
	for other_path in range(array_to_inspect.size()):
		if point < array_to_inspect[other_path].size():
			var secondary_point = array_to_inspect[other_path][point] as Vector2
			if (rogue_paths.keys().filter(func(vec : Vector2):	
					return CustomMath.compare_vectors(vec, secondary_point)) == []):
				rogue_paths[secondary_point] = [array_to_inspect[other_path]]
			else:
				for i in rogue_paths.keys():
					if CustomMath.compare_vectors(i, secondary_point):
						rogue_paths[i].append(array_to_inspect[other_path])
	return rogue_paths

func _find_longest_path(array_to_inspect) -> int:
	var longest_id = 0
	var longest_size = 0
	for path in range(array_to_inspect.size()):
		if array_to_inspect[path].size() > longest_size:
			longest_id = path
			longest_size = array_to_inspect[path].size()
	return longest_id	

func _get_uniqe_tail_array_vector(arr_of_arrs, start_point):
	var base_point = arr_of_arrs.keys()[0]
	var array_to_inspect = []
	array_to_inspect = arr_of_arrs[base_point]
	if arr_of_arrs[base_point].size() <= 1 or arr_of_arrs[base_point][0] is Vector2i or arr_of_arrs[base_point][0] is Vector2:
		var go_path_array = array_to_inspect[0][-1]
		return go_path_array
	var point = start_point+1
	var rogue_paths = _generate_rogue_path(point, array_to_inspect)
	var longest_path = array_to_inspect[_find_longest_path(array_to_inspect)]

	var path_count = {}
	for path in rogue_paths.keys():
		path_count[path] = rogue_paths[path].size()
	var prev_point = longest_path[point-1]
	var go_points_arr = {}
	if rogue_paths.size() >1:
		go_points_arr = {prev_point: []}
		for path in rogue_paths.keys():
			go_points_arr[prev_point].append(_get_uniqe_tail_array_vector({prev_point: rogue_paths.get(path)}, point))
	else:
		if path_count.values().max() >1:
			go_points_arr = _get_uniqe_tail_array_vector({base_point: rogue_paths[rogue_paths.keys()[0]]}, point)
	rogue_paths = {}
	return go_points_arr

func generate_path_map(start_point, points_of_interest):
	var path_array = {start_point: []}
	for point in points_of_interest:
		path_array[start_point].append(astar_grid.get_point_path(start_point, point))
	var road_dict =_get_uniqe_tail_array_vector(path_array, 0)
	return road_dict





