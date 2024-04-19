extends CharacterBody2D


@onready var attack_1_component = $Attack1Component as AttackComponent

func _ready():
	attack_1_component.attack_finished.connect(_on_attack_1_component_attack_finished)
	attack_1_component.attack()
	pass # Replace with function body.


func _process(_delta):
	pass

func _on_attack_1_component_attack_finished():
	attack_1_component.attack()
