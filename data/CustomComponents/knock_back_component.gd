@icon("res://CustomComponents/CustomComponentIcons/knockback.png")
class_name KnockBackComponent extends Node




func knockback(value, enemy_pos: Vector2):
	var to_enemy_direction : Vector2 = (enemy_pos - get_parent().position).normalized()
	#print(to_enemy_direction, "  ", value)
	get_parent().position = get_parent().position - to_enemy_direction*value*10
	
