extends MarginContainer




@export var treasure : Treasure 

@onready var texture_rect = %TextureRect as TextureRect
@onready var recepie_name_lable = %RecepieNameLabel as Label
@onready var souls_recepie = %SoulsRecepie as HBoxContainer
@onready var button = %Button as Button

# Подключить нажатие : $TreasureContainer.button.pressed.connect(<function_name>.bind(new_recepie_container.treasure))

func _ready():
	texture_rect.set_texture(ImageTexture.create_from_image(treasure.icon))
	recepie_name_lable.set_text(treasure.name)
	for soul in recepie:
		var new_image = TextureRect.new()
		# FIXME сейчас квадраты очень больше, из-за того что текстуры по разному импортированы и разного размера.
		# в будущем нужно поменять на  TextureRect.EXPAND_FIT_WIDTH (?)
		new_image.set_expand_mode(TextureRect.EXPAND_KEEP_SIZE)
		new_image.set_texture(soul.get_preview())
		souls_recepie.add_child(new_image)
