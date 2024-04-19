class_name TestHero extends BaseHero


@onready var attack_1_component = $Attack1Component as AttackComponent

func _ready():
	super()
	attack_1_component.attack()


func point_choose_logic(path_variants):
	return super(path_variants)


func _target_reached():
	if target_reached:
		return

	if known_points_of_interest_astar.size() < 2:
		target_reached = true
		pathfinder.stop_pathfinding()
		return
	if on_way_to_final:
		print("Я достиг конца")
		reset_starting_point(current_path_map)
		debug_mode = false
		var final_point = known_points_of_interest_global.filter(func(point): return CustomMath.compare_vectors(point, current_path_map))[0]
		var final_point_index = known_points_of_interest_global.find(final_point)
		known_points_of_interest_global.pop_at(final_point_index)
		var current_point = known_points_of_interest_astar.pop_at(final_point_index)
		on_way_to_final = false
		await generate_path_map(current_point)
		_init_hero_movement()
	else:
		print("Развилка")
		get_next_point()
	pathfinder.makepath()
	# target_reached = true
	# FIXME 
	#get_tree().quit()





func _on_attack_1_component_attack_finished():
	attack_1_component.attack()


