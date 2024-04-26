extends MarginContainer


signal soul_selected

@export var soul_options : Array[Soul]

var slot_id
var index_to_sprite_dict = {} as Dictionary

@onready var option_button = %OptionButton as OptionButton
@onready var texture_button = %TextureButton as TextureButton


func _ready():
	for soul in soul_options:
		option_button.add_item(soul.name, soul.type)
		index_to_sprite_dict[soul.type] = soul.sprite.get_frame_texture("default",0)
	option_button.item_selected.connect(_set_button_sprite)
	option_button.item_selected.connect(_soul_selected_emit)

	option_button.select(-1)

# HACK
func _soul_selected_emit(_item):
	soul_selected.emit()

func _set_button_sprite(index):
	if index == -1:
		texture_button.texture_normal = null
	else:
		var id = option_button.get_item_id(index)
		texture_button.set_texture_normal(index_to_sprite_dict[id])
	
		
func select_item(index):
	option_button.select(index)
	_set_button_sprite(index)
	soul_selected.emit()
