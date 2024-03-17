@icon("res://CustomComponents/CustomComponentIcons/bell.png")
class_name HurtBoxComponent extends Area2D


@export var health_component : HealthComponent

@export var knockback_component : KnockBackComponent

@onready var got_hit_by_list : Array

## 
func hurt(damage: float):
	health_component.decrease(damage)

func knockback(value : float, area: Node2D):
	if knockback_component:
		knockback_component.knockback(value, area.global_position)
	pass


## Проверяем, что компонент здоровья подключен. 
## иначе урон проходить не будет!
func _ready():
	DebugTools.check_null(health_component, "HealthComponent", self, true)




func _on_area_entered(area):
	#print("area detected ", area)
	if (area is AttackComponent):
		area = area as AttackComponent
		## проверяем, что этот хитбокс уже нанес урон в этой атаке
		### (на случай если сущность будет крутится 
		### и хитбокс попадет несколько раз)
		if got_hit_by_list.find(area) == -1:
			## добавляем в массив игнорируемых хитбоксов
			got_hit_by_list.append(area)
			
			#var this_thing = selfd
			## привязываем сигнал об окончании атаки к удалению из массива
			## чтобы хитбокс мог снова наносить урон
			area.attack_finished.connect(_on_attack_finished.bind(area), 4)
			
			#print(area_owner.attack_finished, " bind ", area, " ", _on_attack_finished)
			#print("Array is : ", got_hit_by_list)
			
			hurt(area.damage)
			knockback(area.knockback, area)

## удаляем объект из массива перед тем, как атака повторится
func _on_attack_finished(finished_attack):
	got_hit_by_list.erase(finished_attack)
