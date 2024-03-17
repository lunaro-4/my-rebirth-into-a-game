@icon("res://CustomComponents/CustomComponentIcons/plus.png")
class_name HealthComponent extends Node


## Максимальное количество здоровья
@export var max_health : int
## Здоровье на момент спавна объекта. При 0 приравнивается к максимальному
@export var start_health: float = 0
## Является ли объект "Живым" на момент спавна
@export var alive : bool = true

@export var hp_bar : Node


var current_health : float = start_health



signal on_death
signal on_health_decrease(value : float)
signal hp_changed(value: float)


## 
func decrease(damage):
	current_health -= damage
	on_health_decrease.emit(damage)
	hp_changed.emit(current_health)
	if current_health <= 0:
		alive = false
		on_death.emit()
	pass

## 
func increase(heal):
	current_health += heal
	hp_changed.emit(current_health)
	#print(max_health, " INCR ", current_health)
	if current_health > max_health:
		current_health = max_health
	pass


## 
func _ready():
	if start_health == 0:
		current_health =max_health
	hp_changed.emit(current_health)
	pass 

func multiply_health(value):
	max_health *= value
	increase(max_health)
	#print(max_health, " MULT ", current_health)



func _on_hp_changed(_value):
	if hp_bar :
		hp_bar.max_value = max_health
		hp_bar.value = _value
	if current_health > max_health:
		current_health = max_health
	if current_health <= 0:
		alive = false
		on_death.emit()
	#print(max_health, "  ", current_health)
	pass # Replace with function body.
