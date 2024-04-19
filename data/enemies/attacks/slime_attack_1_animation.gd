extends Node2D


@export var anim_poly :Polygon2D

func animate(_hit_wait):
	anim_poly.color.a = 0.8
	var fade_interval = _hit_wait/20
	for i in range(20):
		await get_tree().create_timer(fade_interval).timeout
		anim_poly.color.a -= 0.05 
	pass

func animate_delay(_delay_wait, _hit_wait):
	pass

func _on_attack_sprite_animation_finished():
	pass

