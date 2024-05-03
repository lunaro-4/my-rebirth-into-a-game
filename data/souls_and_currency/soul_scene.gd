class_name SoulScene extends AnimatableBody2D

signal soul_collected

@onready var soul : Soul

@onready var soul_sprite = $SoulSprite as AnimatedSprite2D

var soul_value : float

func _ready():
	soul_sprite.sprite_frames = soul.sprite


func _input_event(_viewport, event : InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		soul_collected.emit()
		add_points()
		animation()

func animation():
	# TODO some animation idk
	# queue_free()
	pass

func add_points():
	PlayerState.on_soul_pickup(soul, soul_value)


