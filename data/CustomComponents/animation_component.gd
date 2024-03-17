@icon("res://CustomComponents/CustomComponentIcons/animation.png")
class_name AnimationComponent extends Node

@export var main_sprite : AnimatedSprite2D

@export var attack_sprite_1 : AnimatedSprite2D
@export var delay_sprite_1 : AnimatedSprite2D


@export var invert_h_flip : bool
@export var horisontal_flip : bool
@export var vertical_flip : bool
@export var look_at_target : Node2D

const EMPTY_VECTOR = Vector2(0,0)

var direction :Vector2

@onready var animation_object = get_parent() as Node2D
#@onready var direction : Vector2

func _ready():
	DebugTools.check_null(main_sprite, 'AnimatedSprite2D', self, true)
	if attack_sprite_1:
		attack_sprite_1.animation_looped.connect(_on_attack_sprite_1_animaton_looped)
	if delay_sprite_1:
		delay_sprite_1.animation_looped.connect(_on_delay_sprite_1_animaton_looped)
	pass


func h_flip_sprite(sprite: AnimatedSprite2D):

	if (direction.x >= 0 and invert_h_flip) or (direction.x < 0 and !invert_h_flip):
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	pass


func animate(switch : bool, _direction: Vector2 = EMPTY_VECTOR):
	direction = _direction
	if switch:
		main_sprite.play()
	elif switch == false:
		
		main_sprite.stop()
		return
	if direction != EMPTY_VECTOR:
		h_flip_sprite(main_sprite)
		



func animate_attack(hit_wait : float, attack_index : int = 1):
	main_sprite.visible = false
	if attack_index == 1:
		DebugTools.check_null(attack_sprite_1, "AttackSprite1", self, true)
		attack_sprite_1.sprite_frames.set_animation_speed("default", 1)
		attack_sprite_1.set_frame(0)
		attack_sprite_1.visible = true
		var speed = attack_sprite_1.sprite_frames.get_frame_count("default")/hit_wait
		attack_sprite_1.play("", speed)
		h_flip_sprite(attack_sprite_1)
		pass
	pass


func _on_attack_sprite_1_animaton_looped():
	main_sprite.visible = true
	attack_sprite_1.visible = false
	pass


func _on_delay_sprite_1_animaton_looped():
	### TODO 
	pass


# main_sprite.rotation =to_local(player.get_global_position()).angle()


