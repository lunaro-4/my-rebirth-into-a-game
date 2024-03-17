class_name RegenerationComponent extends Node


@export var regen_cycle_span : float = 1 

@export var regen_amount : float = 0

@export var health_component : HealthComponent

## Если выключен, лечение не будет исходить, даже если регенерация активна
@export var regeneration_status : bool = true

@onready var regen_timer = $RegenCycleTimer as Timer


## Проверяем, что компонент здоровья подключен. 
## иначе лечение проходить не будет!
func _ready():
	if health_component == null:
		print("Health component not attached at: ", self, " ", get_parent())
		assert(health_component != null) 
	regen_timer.wait_time = regen_cycle_span


func regen_stop(): 
	regen_timer.stop()

func regen_start():
	regen_timer.start()

func send_regen():
	if regeneration_status:
		health_component.increase(regen_amount)


func _on_regen_cycle_timer_timeout():
	send_regen()

