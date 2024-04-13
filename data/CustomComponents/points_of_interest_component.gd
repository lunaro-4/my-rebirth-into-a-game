class_name PointsOfInterestComponent extends Node2D



@export var STARTING_POINT : Vector2i

var astar_grid : AStarGrid2D

var points_of_interest : Array[Vector2i] 
signal map_ready 

func generate_path():
	var point_pos := astar_grid.get_point_path(STARTING_POINT, points_of_interest[0])[-2]
	var point_of_interest = Marker2D.new()
	point_of_interest.position = point_pos
	add_child(point_of_interest)
	return point_of_interest

func _get_uniqe_tail_array_vector(arr_of_arrs, start_point):
	var base_point = arr_of_arrs.keys()[0]
	var array_to_inspect = []
	array_to_inspect = arr_of_arrs[base_point]
	if arr_of_arrs[base_point].size() <= 1 or arr_of_arrs[base_point][0] is Vector2i or arr_of_arrs[base_point][0] is Vector2:
		
		var go_path_array = array_to_inspect[0][-1]
		return go_path_array
	var rogue_paths = {}
	var longest_id = 0
	var longest_size = 0
	for path in range(array_to_inspect.size()):
		if array_to_inspect[path].size() > longest_size:
			longest_id = path
			longest_size = array_to_inspect[path].size()
	var point = start_point+1
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
	
	var path_count = {}
	for path in rogue_paths.keys():
		path_count[path] = rogue_paths[path].size()
	var prev_point = array_to_inspect[longest_id][point-1]
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

func generate_path_map(start_point):
	var path_array = {start_point: []}
	for point in points_of_interest:
		path_array[start_point].append(astar_grid.get_point_path(start_point, point))
		print("---------")
		for place in astar_grid.get_point_path(start_point, point):
			print("Vector2",place,",")
	var road_dict =_get_uniqe_tail_array_vector(path_array, 0)
	print("#############################")
	# print(road_dict)
	return road_dict

func _find_next_point(paths, crossroad_points) -> Vector2i:
	if !paths[0] is Vector2i:
		paths = paths[0]	
	for point in paths:
		for crossroad in  crossroad_points:
			if CustomMath.compare_vectors(crossroad, point):
				return crossroad as Vector2i
	return paths[-1]


func set_next_point(paths_array, left_crossroad_points) -> Vector2i:
	return _find_next_point(paths_array, left_crossroad_points)
	# for point in path_map.keys():
	# 	if CustomMath.compare_vectors(point, current_pos):
	# 		return _find_next_point(path_map[point].values()[randi()%path_map[point].size()], path_map.keys())
	# assert(false)
	# return Vector2i()






