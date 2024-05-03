extends HSlider

@export var health_component : HealthComponent


func _process(_delta):
	max_value = health_component.max_health
	value = health_component.current_health
	if value == max_value and health_component.alive:
		visible = false
	else:
		visible = true
