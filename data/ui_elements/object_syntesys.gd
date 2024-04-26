extends PanelContainer

const CRAFTING_SIZE = 3

var soul_choice = preload("res://data/ui_elements/soul_choice.tscn")
var soul_stat_container = preload("res://data/ui_elements/soul_stat_container.tscn")
var recepie_container = preload("res://data/ui_elements/recepie_container.tscn") 
var available_souls = [
	load("res://data/souls_and_currency/red_soul.tres"),
	load("res://data/souls_and_currency/blue_soul.tres"),
	load("res://data/souls_and_currency/green_soul.tres")
] as Array[Soul]
var known_recepies = [
	load("res://data/level_objects/enemies/slime.tres"), 
	load("res://data/level_objects/obstacles/door_lock.tres")
]
var known_recepies_in_types = {} as Dictionary
var soul_button_array = []

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
	for soul in available_souls:
		var new_soul_container = soul_stat_container.instantiate()
		new_soul_container.soul_to_show = soul
		soul_stat_list.add_child(new_soul_container)
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
	var recepie_pos = known_recepies_in_types.values().find(current_recepie)
	if recepie_pos != -1:
		var this_found_recepie = known_recepies_in_types.keys()[recepie_pos]
		result_image.set_texture(ImageTexture.create_from_image(this_found_recepie.icon))
		object_name.set_text(this_found_recepie.name)
		pass
	pass
