extends MarginContainer


# const SOULS_LEFT = {
# 	Soul.SoulType.RED : 12,
# 	Soul.SoulType.GREEN : 3,
# 	Soul.SoulType.BLUE : 7
# }

@export var soul_to_show : Soul

var container_id 
var initial_souls_left
var current_souls_left

@onready var texture_rect = %TextureRect as TextureRect
@onready var soul_name_lable = %SoulNameLable as Label
@onready var left_num = %LeftNum as Label
@onready var to_spend_num = %ToSpendNum as Label
@onready var to_spend_text = %ToSpendText as Label


func _ready():
	update_soul(initial_souls_left)
	set_to_spend(0)

func update_soul(souls_left):
	if souls_left == null:
		souls_left = 0
	# var soul_left_dict = SOULS_LEFT
	container_id = soul_to_show.type
	soul_name_lable.text = str(soul_to_show.name)
	texture_rect.texture = soul_to_show.get_preview()
	current_souls_left = souls_left
	left_num.text = str(souls_left)

func set_to_spend(amount: float):
	var is_change_viable = true
	if amount == 0:
		to_spend_text.visible = false
		to_spend_num.visible = false
	else:
		to_spend_text.visible = true
		to_spend_num.visible = true
		if amount > 0:
			to_spend_text.set_text("-")
			if current_souls_left - amount < 0:
				is_change_viable = false
		else:
			amount *= -1
			to_spend_text.set_text("+")
	to_spend_num.set_text(str(amount))
	return is_change_viable
	
