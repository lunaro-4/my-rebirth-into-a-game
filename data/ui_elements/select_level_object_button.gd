extends MarginContainer


@export var level_object : LevelObject


@onready var texture_button = %TextureButton as TextureButton

@onready var button_label = %ButtonLabel as Label

signal button_pressed(level_object)

func _ready():
	var texture_to_set = ImageTexture.create_from_image(level_object.icon) as ImageTexture
	texture_to_set.set_size_override(Vector2i(64,64))
	texture_button.set_texture_normal(texture_to_set)
	button_label.set_text(level_object.name)
	texture_button.pressed.connect(_button_pressed)

func _button_pressed():
	button_pressed.emit(level_object)


