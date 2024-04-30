extends PanelContainer

const CRAFTING_SIZE = 3
const EMPTY_SOUL_ARRAY = {
	Soul.SoulType.RED : 0,
	Soul.SoulType.GREEN : 0,
	Soul.SoulType.BLUE : 0
}


@export var soul_choice : PackedScene
@export var recepie_container : PackedScene


var available_souls = [
	load("res://data/souls_and_currency/red_soul.tres"),
	load("res://data/souls_and_currency/blue_soul.tres"),
	load("res://data/souls_and_currency/green_soul.tres")
] as Array[Soul]
var souls_left : Dictionary
var known_recepies = [
	load("res://data/level_objects/enemies/slime.tres"), 
	load("res://data/level_objects/obstacles/door_lock.tres")
]
var known_recepies_in_types = {} as Dictionary
var soul_button_array = []
var soul_stat_container_array = []
var creatable_object 
var selected_recepie


@onready var buttons_container = %ButtonsContainer  as HBoxContainer
@onready var soul_stat_list = %SoulStatList as VBoxContainer
@onready var recepie_list = %RecepiesList
@onready var result_image = %ResultImage as TextureRect
@onready var object_name = %ObjectName as Label
@onready var create_button = %CreateButton as Button


func _ready():
	available_souls.sort_custom(func(soul1, soul2): return soul1.type < soul2.type)

	for slot in range(CRAFTING_SIZE):
		var new_soul_button = soul_choice.instantiate()
		new_soul_button.soul_options = available_souls
		new_soul_button.slot_id = slot
		new_soul_button.soul_selected.connect(_on_soul_selected)
		soul_button_array.append(new_soul_button)
		buttons_container.add_child(new_soul_button)

	soul_stat_list.pupulate_list(available_souls)

	for recepie in known_recepies:
		var new_known_recepie_in_type = []
		for soul in recepie.recepie:
			new_known_recepie_in_type.append(soul.type)
		while new_known_recepie_in_type.size() < CRAFTING_SIZE:
			new_known_recepie_in_type.append(-1)
		known_recepies_in_types[recepie] = new_known_recepie_in_type
		var new_recepie_container = recepie_container.instantiate()
		new_recepie_container.object = recepie
		recepie_list.add_child(new_recepie_container)
		new_recepie_container.button.pressed.connect(set_recepie.bind(new_recepie_container.object.recepie))

	create_button.pressed.connect(_create_object)
	PlayerState.inventory_updated.connect(_update_invetnory)
	
func clear_selection():
	for i in soul_button_array:
		i.select_item(-1)

func set_recepie(recepie: Array[Soul]):
	if recepie.size() > soul_button_array.size():
		printerr("Attempt to craft too large recepie")
		return
	clear_selection()
	for soul in range(recepie.size()):
		soul_button_array[soul].select_item(recepie[soul].type)
	pass

func _on_soul_selected():
	var current_recepie = []
	for soul in range(soul_button_array.size()):
		current_recepie.append(soul_button_array[soul].option_button.get_selected_id())
	selected_recepie = current_recepie
	var recepie_pos = known_recepies_in_types.values().find(current_recepie)
	if recepie_pos != -1:
		var this_found_recepie = known_recepies_in_types.keys()[recepie_pos]
		var image_texture = ImageTexture.create_from_image(this_found_recepie.icon)
		image_texture.set_size_override(Vector2i(104,104))
		result_image.set_texture(image_texture)
		object_name.set_text(this_found_recepie.name)
		creatable_object = this_found_recepie
		# TODO добавить проверку на возможность крафта по цене душ
		create_button.disabled = false
		var set_to_spend = EMPTY_SOUL_ARRAY.duplicate()
		for soul in selected_recepie:
			if soul == -1:
				continue
			set_to_spend [soul] += 1
		soul_stat_list.update_set_to_spend(set_to_spend)

	else: 
		result_image.set_texture(null)
		object_name.set_text('')
		creatable_object = null
		create_button.disabled = true
		soul_stat_list.update_set_to_spend(EMPTY_SOUL_ARRAY)


func _create_object():
	# print(creatable_object)
	var new_object = LevelObject.new()
	new_object.name = creatable_object.name
	# new_object.object_scene = creatable_object.object_scene.duplicate()
	# new_object.icon = creatable_object.icon.duplicate()
	new_object.object_scene = creatable_object.object_scene
	new_object.icon = creatable_object.icon
	new_object.type = creatable_object.type
	new_object.scale = creatable_object.scale
	new_object.recepie = creatable_object.recepie.duplicate()
	PlayerState.add_object_to_inventory(new_object)
	var spend_count = {} as Dictionary
	for soul in selected_recepie:
		if soul == -1:
			continue
		if spend_count.keys().has(soul):
			spend_count [soul] += 1
		else:
			spend_count [soul] = 1
	PlayerState.spend_souls(spend_count)


func _on_save_pressed():
	PlayerState.save_player_state()

func _on_load_pressed():
	PlayerState.load_player_state()

func _update_invetnory():
	# souls_left = PlayerState.get_inventory()
	pass


