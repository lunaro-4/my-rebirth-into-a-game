extends MarginContainer


const SOULS_LEFT = {
	Soul.SoulType.RED : 12,
	Soul.SoulType.GREEN : 3,
	Soul.SoulType.BLUE : 7
}

@export var soul_to_show : Soul

var container_id 

@onready var texture_rect = %TextureRect as TextureRect
@onready var soul_name_lable = %SoulNameLable as Label
@onready var left_num = %LeftNum as Label
@onready var to_spend_num = %ToSpendNum as Label
@onready var to_spend_text = %ToSpendText as Label


func _ready():
	update_soul()

func update_soul():
	var soul_left_dict = SOULS_LEFT
	container_id = soul_to_show.type
	soul_name_lable.text = str(soul_to_show.name)
	texture_rect.texture = soul_to_show.sprite.get_frame_texture("default",0)	
	left_num.text = str(soul_left_dict[soul_to_show.type])
	set_to_spend(0)

func set_to_spend(amount: float):
	if amount == 0:
		to_spend_text.visible = false
		to_spend_num.visible = false
	else:
		to_spend_text.visible = true
		to_spend_num.visible = true
		if amount > 0:
			to_spend_text.set_text("-")
		else:
			to_spend_text.set_text("+")
	to_spend_num = str(amount)	
