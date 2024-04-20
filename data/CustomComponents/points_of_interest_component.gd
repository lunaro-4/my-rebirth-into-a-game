class_name PointsOfInterestComponent extends Node2D



# @export var STARTING_POINT : Vector2i

var astar_grid : AStarGrid2D

signal map_ready 

## Изучаем массив на предмет расхождения в конкретном индексе
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

## Ищем самый длинный массив в матрице
func _find_longest_path(array_to_inspect) -> int:
	var longest_id = 0
	var longest_size = 0
	for path in range(array_to_inspect.size()):
		if array_to_inspect[path].size() > longest_size:
			longest_id = path
			longest_size = array_to_inspect[path].size()
	return longest_id	

## Смотрим на группы путей и решаем, как их обработать
func _handle_rogue_paths(base_point, current_point_int, prev_point, rogue_paths):
	var path_count = {}
	# Считаем, сколько массивов в каждой группе
	for path in rogue_paths.keys():
		path_count[path] = rogue_paths[path].size()
	# var prev_point = longest_path[point-1]
	var go_points_arr = {}
	# Обработать каждую группу
	# Если находимся на точке развилки, обрабатывем пути из каждой группы
	if rogue_paths.size() >1:
		go_points_arr = {prev_point: []}
		for path in rogue_paths.keys():
			go_points_arr[prev_point].append(_get_uniqe_tail_array_vector({prev_point: rogue_paths.get(path)}, current_point_int))
	# Если в единственной группе много массивоы, идти по ним с сохранением последней точки развилки, пока не найдем новую развилку
	else:
		if path_count.values().max() >1:
			go_points_arr = _get_uniqe_tail_array_vector({base_point: rogue_paths[rogue_paths.keys()[0]]}, current_point_int)
	return go_points_arr

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
	
	var go_points_arr = _handle_rogue_paths(base_point, point, longest_path[point-1], rogue_paths)

	if go_points_arr == {}:
		go_points_arr = {base_point:base_point}
	if go_points_arr == {}:
		assert(false)

	return go_points_arr

## Генерируем карту пути. [br][br]
## ВАЖНО : Массив с точками интересов должен быть
## сформирован относительно AStarGrid, тоесть содежать
## именно координаты на сетке
func generate_path_map(start_point, points_of_interest) -> Dictionary:
	DebugTools.check_null_value(astar_grid, "AStarGrid", self, true)
	# print(points_of_interest)
	var path_array = {start_point: []}
	for point in points_of_interest:
		path_array[start_point].append(astar_grid.get_point_path(start_point, point))
	var road_dict =_get_uniqe_tail_array_vector(path_array, 0)
	if not road_dict is Dictionary:
		road_dict = {road_dict:road_dict}
	return road_dict





