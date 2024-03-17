@icon("res://CustomComponents/CustomComponentIcons/sword_b.png")
class_name AttackComponent extends Area2D

## how much damage will HurtBox rescive
@export var damage :float


## Модификатор откидывания атаки
@export var knockback : float



## Задержка перед атакой
@export var delay : float = 0
## Длительность активности хитбокса атаки
@export var hit_window : float
## Модификатор скорости атаки
@export var speed_modifyer : float = 1

# Закрыватель атаки, чтобы до её завершения
# нельзя было начать новую
var attack_is_on : bool

var base_damage = damage



func _ready():
	if speed_modifyer == 0:
		speed_modifyer = 1
	else:
		speed_modifyer = 1 / speed_modifyer
	pass


func _process(_delta):
	rotate_and_follow()




###########################################################
# Атака
###########################################################

signal attack_finished

## Метод атаки
func attack():
	if attack_is_on:
		return
	attack_is_on = true
	## Ускоряем задержку
	var delay_wait = delay * speed_modifyer
	var hit_wait = hit_window * speed_modifyer
	# анимируем и ждем задержку (ненадежно?)
	animate_delay(delay_wait, hit_wait) 
	await wait(delay_wait)
	# анимируем саму атаку и параллельно включаем хитбоксы
	animate_attack(hit_wait)
	var hitbox_collisions_array := get_children().filter(func(shape):
		return shape.get_class() == "CollisionShape2D")
	swich_hitbox_state(hitbox_collisions_array, false)
	await wait(hit_wait)
	# по завершению атаки выключаем хитбоксы 
	# и даем всем знать, что атака закончена
	swich_hitbox_state(hitbox_collisions_array, true)
	attack_is_on = false
	attack_finished.emit()



func swich_hitbox_state(array : Array, state : bool):
	for item in array:
		item.disabled = state



###########################################################
# Анимации
###########################################################


## Захват позиции курсора
const DEFAULT_POSITION = Vector2(0,0)
var mouse_position := DEFAULT_POSITION


## Указатель компонента анимации данной атаки [br][br]
## Нужно вставить композитора, ответственного
## за перемещение хитбоксов
@export var hit_animation_object : Node



## Перемещать Хитбокс под курсор?
@export var follow_coursor : bool = false

## Направлять хитбокс в сторону курсора?
@export var ray_coursor : bool = false

## Дополнительный угол к направлению на курсор
@export var add_rotation: float = 0

## Опциональная цель атаки [br][br]
## !!использование с ray_coursor опасно!!
@export var ray_target : Node2D

## Если компонент анимации подключен, посылаем сигнал анимации атаки
func animate_attack(hit_wait):
	if hit_animation_object != null and hit_animation_object.has_method("animate"):
		hit_animation_object.animate(hit_wait)
		
## Если компонент анимации подключен, посылаем сигнал анимации задержки
func animate_delay(delay_wait, hit_wait):
	if hit_animation_object != null and hit_animation_object.has_method("animate_delay"):
		hit_animation_object.animate_delay(delay_wait, hit_wait)

func rotate_and_follow():
	if follow_coursor:
		position =  get_global_mouse_position() - get_parent().global_position
	if ray_coursor:
		look_at(get_global_mouse_position())
		rotation_degrees += add_rotation
	if ray_target != null:
		look_at(ray_target.global_position)
		rotation_degrees += add_rotation





###########################################################
# Функциональные методы
###########################################################

## Метод для возможности начала новой атаки до завершения старой
func interrupt_attack():
	attack_is_on = false

func tweak_damage(value):
	damage = value * base_damage

func wait(time) -> void:
	await get_tree().create_timer(time).timeout
	


