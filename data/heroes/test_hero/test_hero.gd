class_name TestHero extends BaseHero


@onready var attack_1_component = $Attack1Component as AttackComponent


func _ready():
	super()
	attack_1_component.attack()


func point_choose_logic(path_variants):
	return super(path_variants)


func _target_reached():
	if !state_explore:
		return
	if target_reached:
		return

	if known_points_of_interest_astar.size() < 2:
		target_reached = true
		pathfinder.stop_pathfinding()
		print(self,' done')
		return
	if on_way_to_final:
		# print("Я достиг конца")
		reset_starting_point(current_path_map)
		debug_mode = false
		var final_point = known_points_of_interest_global.filter(func(point): return CustomMath.compare_vectors(point, current_path_map))[0]
		var final_point_index = known_points_of_interest_global.find(final_point)
		known_points_of_interest_global.pop_at(final_point_index)
		var current_point = known_points_of_interest_astar.pop_at(final_point_index)
		on_way_to_final = false
		await _generate_path_map(current_point)
		_init_hero_movement()
	else:
		# print("Развилка")
		get_next_point()
	pathfinder.makepath()
	# target_reached = true
	# FIXME 
	#get_tree().quit()





func _on_attack_1_component_attack_finished():
	attack_1_component.attack()


func _on_enemy_detected(body):
	_on_enemy_forgotten()
	if body is BaseMinion and body != self:
		detected_enemy = body
		_connect_enemy_death(true,_on_enemy_forgotten)
		state_chart.send_event("enemy_detected")
	pass # Replace with function body.

func _on_enemy_undetected(body):
	# print(_body)
	if body is BaseMinion and body != self:
		_connect_enemy_death(false,_on_enemy_forgotten)
		state_chart.send_event("enemy_undetected")
		await get_tree().create_timer(0.01).timeout
		if !is_instance_valid(body):
			_redetect_enemies()

# func _on_enemy_detection_area_area_entered(_area:Area2D):
# 	$StateChart.set_event("enemy_detected")
# 	pass # Replace with function body.




func _on_death():
	super()
