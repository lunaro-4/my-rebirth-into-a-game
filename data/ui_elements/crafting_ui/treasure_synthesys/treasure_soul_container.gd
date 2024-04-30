extends VBoxContainer


signal value_changed(current_value)

@export var soul : Soul

var last_text_input
var container_id : int
var current_soul_value


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
	current_soul_value = slider.value
	value_changed.emit(current_soul_value)
	pass
func _on_slider_value_changed(_value):
	manual_input.value = slider.value
	current_soul_value = manual_input.value
	value_changed.emit(current_soul_value)
	pass


func set_new_value(value : float):
	slider.set_value_no_signal(value)
	manual_input.set_value_no_signal(value)
