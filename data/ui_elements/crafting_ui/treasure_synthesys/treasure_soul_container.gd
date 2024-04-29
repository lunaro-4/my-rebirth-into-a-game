extends VBoxContainer


@export var soul : Soul

var last_text_input


@onready var manual_input = %ManualInput as SpinBox
@onready var slider = %Slider as HSlider
@onready var left_button = %Left as Button
@onready var right_button = %Right as Button
@onready var texture_rect = %TextureRect as TextureRect
@onready var label = %Label as Label

func _ready():
	if soul:
		label.text = soul.name
		texture_rect.texture = soul.get_preview()
		
	left_button.pressed.connect(_on_left_pressed)
	right_button.pressed.connect(_on_right_pressed)
	manual_input.value_changed.connect(_on_manual_input_changed)
	slider.value_changed.connect(_on_slider_value_changed)

func update_value(value):
	manual_input.value = value


func _on_left_pressed():
	slider.value -= slider.step
func _on_right_pressed():
	slider.value += slider.step
func _on_manual_input_changed(_value):
	slider.value = manual_input.value
	pass
func _on_slider_value_changed(_value):
	manual_input.value = slider.value
	pass
