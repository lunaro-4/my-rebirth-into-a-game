extends BaseHero


@onready var attack_1_component = $Attack1Component as AttackComponent


func _ready():
	super()
	attack_1_component.attack()
	_available_interactions.append(InteractableObject.InteractionTypes.THIEF_UNLOCK)


func point_choose_logic(path_variants):
	return super(path_variants)


func _target_reached():
	if current_state != State.EXPLORE:
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
		if current_path_map is Dictionary:
			on_way_to_final = false
			get_next_point()
		else:
			_point_exclude_and_move_on(current_path_map)
			_init_hero_movement()
	else:
		get_next_point()
	pathfinder.makepath()





func _on_attack_1_component_attack_finished():
	attack_1_component.attack()


func _on_enemy_detected(body):
	if detected_enemy != null:
		return
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


func _on_death():
	super()

