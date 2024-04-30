extends VBoxContainer

@export var soul_stat_container : PackedScene

var souls_array : Array[Soul]
var souls_left : Dictionary
var soul_stat_container_array : Array[Control]

# Использование :
#
# func _ready():
#    soul_stat_list.pupulate_list(available_souls)
#


func _ready():
	_update_souls()

	PlayerState.soul_amount_updated.connect(_update_souls)

func _clear_list():
	for child in get_children():
		child.queue_free()

func pupulate_list(_souls_array):
	souls_array = _souls_array
	_clear_list()
	for soul in souls_array:
		var new_soul_container = soul_stat_container.instantiate()
		new_soul_container.soul_to_show = soul
		new_soul_container.initial_souls_left = souls_left [soul.type]
		add_child(new_soul_container)
		soul_stat_container_array.append(new_soul_container)



func update_set_to_spend(set_to_spend : Dictionary):
	var is_change_viable = true
	for soul in set_to_spend.keys():
		for container in soul_stat_container_array:
			if container.container_id  == soul:
				if set_to_spend [soul] != null:
					var is_set_ok = container.set_to_spend(set_to_spend [soul])
					is_change_viable = is_change_viable and is_set_ok 
					# print(is_change_viable, is_set_ok)
				continue
	return is_change_viable

func reset_value_change():
	for container in soul_stat_container_array:
		container.set_to_spend(0)

func _update_souls():
	souls_left = PlayerState.get_souls()
	for container in soul_stat_container_array:
		container.update_soul(souls_left [container.soul_to_show.type])
