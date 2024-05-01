extends PanelContainer


@export var treasure_container : PackedScene

var available_souls : Array[Soul]

var soul_to_containers_dict = {}
var soul_before_tweak_value = {}
var chosen_treasure : LevelObject
var treasure_inventory_index = {}

@onready var soul_stat_list = %SoulStatList as VBoxContainer
@onready var treasure_list = %TreasureList as VBoxContainer
@onready var soul_containers_array = [
	%UpperSoulContainer,
	%LowerLeftSoulContainer,
	%LowerRightSoulContainer
] as Array[VBoxContainer]
@onready var confirm_button = %ConfirmButton as Button
@onready var treasure_preview = %TreasurePreview as TextureRect



func _ready():
	available_souls = PlayerState.get_available_souls()

	soul_stat_list.pupulate_list(available_souls)


	for soul in range(available_souls.size()):
		var this_soul = available_souls [soul]
		var this_container = soul_containers_array [soul]
		this_container.soul = this_soul
		this_container.container_id = this_soul.type
		soul_to_containers_dict [this_soul] = this_container
		this_container.value_changed.connect(_update_soul_stats.bind(this_container))
	_update_treasure_list()
	confirm_button.pressed.connect(_commit_changes)
	
func _translate_dict(dict_to_translate : Dictionary):
	var soul_before_tweak_fixed = {}
	for soul in dict_to_translate.keys():
		soul_before_tweak_fixed [ soul.type ] = dict_to_translate [ soul ]

	return soul_before_tweak_fixed

func _change_button_state(state : bool):
	if state and chosen_treasure:
		confirm_button.disabled = false
	else:
		confirm_button.disabled = true


func _update_soul_stats(value : float, sender : Control):
	var before_tweak_dict = _translate_dict(soul_before_tweak_value)
	var before_tweak_value
	if before_tweak_dict.keys().has(sender.container_id) :
		before_tweak_value = before_tweak_dict [sender.container_id]
	else:
		before_tweak_value = 0

	var set_to_spend = { sender.container_id    :   value - before_tweak_value }
	if soul_stat_list.update_set_to_spend(set_to_spend):
		_change_button_state(true)
	else:
		_change_button_state(false)


func _reset_treasure():
	for container in soul_containers_array:
		container.set_new_value(0)
	chosen_treasure = null
	treasure_preview.texture = null
	_change_button_state(false)


func _on_treasure_chosen(treasure : LevelObject):
	soul_before_tweak_value = treasure.get_soul_cost()
	chosen_treasure = treasure
	for container in soul_containers_array:
		for soul in soul_before_tweak_value.keys():
			if container.container_id == soul.type and soul_before_tweak_value [soul] != null:
				container.current_soul_value = soul_before_tweak_value [soul]
				container.set_new_value(container.current_soul_value)
	treasure_preview.texture = ImageTexture.create_from_image(treasure.icon)


func _update_treasure_list():
	for child in treasure_list.get_children():
		child.queue_free()
	var treasures_array = PlayerState.get_treasures()
	for treasure in range(treasures_array.size()):
		var this_treasure = treasures_array [treasure]
		var new_container = treasure_container.instantiate()
		new_container.treasure = this_treasure
		treasure_list.add_child(new_container)
		treasure_inventory_index [ this_treasure] = treasure
		new_container.button.pressed.connect(_on_treasure_chosen.bind(this_treasure))
	
func _commit_changes():
	var values_to_write	= {}
	var value_change = {}
	for container in soul_containers_array:
		var this_soul = container.soul
		var this_value = container.current_soul_value
		values_to_write [this_soul] = this_value

		if !soul_before_tweak_value.keys().has(this_soul):
			soul_before_tweak_value [this_soul] = 0
		var this_value_diff = soul_before_tweak_value [this_soul] - this_value
		value_change [this_soul.type] = this_value_diff

	chosen_treasure.treasure_soul_intake = values_to_write.duplicate()
	PlayerState.update_treasure( treasure_inventory_index [chosen_treasure] , chosen_treasure)
	PlayerState.change_soul_amount(value_change)
	soul_stat_list.reset_value_change()
	_reset_treasure()
	_update_treasure_list()

