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

func _get_uniqe_tail_array_vector(arr_of_arrs, start_point, arr_tails):
	if arr_of_arrs.size() <= 1 or arr_of_arrs[0] is Vector2i or arr_of_arrs[0] is Vector2:
		return arr_tails
	var rogue_paths = {}
	var longest_id = 0
	var longest_size = 0
	for path in range(arr_of_arrs.size()):
		if arr_of_arrs[path].size() > longest_size:
			longest_id = path
			longest_size = arr_of_arrs[path].size()
	if start_point >= arr_of_arrs[longest_id].size():
		return arr_tails
	var point = start_point+1
	for other_path in range(arr_of_arrs.size()):
		if point < arr_of_arrs[other_path].size():
			var secondary_point = arr_of_arrs[other_path][point] as Vector2i
			if (rogue_paths.keys().filter(func(vec : Vector2i):	
					return CustomMath.compare_vectors(vec, secondary_point)) == []):
				rogue_paths[secondary_point] = [arr_of_arrs[other_path]]
			else:
				for i in rogue_paths.keys():
					if CustomMath.compare_vectors(i, secondary_point):
						rogue_paths[i].append(arr_of_arrs[other_path])
	
	var path_count = {}
	for path in rogue_paths.keys():
		path_count[path] = rogue_paths[path].size()
	# print(path_count)
	var go_points_arr = {}
	for key in rogue_paths.keys():
		go_points_arr[key] = rogue_paths[key]
	for path_point in path_count.keys():
			# print("start point", path_point, "path count", path_count[path_point])
			arr_tails =  _get_uniqe_tail_array_vector(rogue_paths[path_point], point, arr_tails)
	if go_points_arr.size()>1:
		arr_tails[arr_of_arrs[longest_id][point-1]] = go_points_arr
	rogue_paths = {}
	return arr_tails

func generate_path_map(start_point):
	var path_array = []
	for point in points_of_interest:
		path_array.append(astar_grid.get_point_path(start_point, point))
		# print(astar_grid.get_point_path(start_point, point))
	var road_dict =_get_uniqe_tail_array_vector(path_array, 0, {})
	var path_keys = road_dict.keys()
	for key in path_keys:
		if road_dict[key].size() <=1:
			road_dict.erase(key)
	# DebugTools.beautiful_dict_print(road_dict)
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






