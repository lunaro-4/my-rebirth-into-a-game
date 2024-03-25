extends Node2D

@onready var texture_trup = preload("res://TestingFolder/textbox.png")
@onready var texture_JIV = preload("res://icon.svg")
@onready var inventory_texture = preload("res://TestingFolder/red.png")
@onready var trup = $Trupi
@onready var Trupeshnik = $CharacterBody2D
#@onready var Inventory = $CanvasLayer/Control
@onready var Item = preload("res://TestingFolder/items.tscn")
@onready var Inventory_inst = preload("res://TestingFolder/Inventory_test_system.tscn")

var item_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	trupi()
	pass

	
func _Click_on_inventory(i):
	if Input.is_action_just_pressed("Right_Mouse_Button"):
		var Inventory_one = Inventory_inst.instantiate()
		$".".add_child(Inventory_one)
		Inventory_one.global_position = i.get_child(0).global_position
		Inventory_one.scale = Vector2(0.3, 0.3)
		var new_item = Item.instantiate()
		new_item.set_item(i.item)
		new_item.on_pick.connect(pick)
		Inventory_one.container_1.get_child(0).add_child(new_item)
		#new_item.global_position = Inventory_one.container_1.get_child(0).global_position
		#new_item.global_position.y = Inventory_one.container_1.get_child(0).global_position.y
		
func trupi():
	var truppp = trup.get_children()
	for i in truppp:
		if ((Trupeshnik.global_position - i.get_child(0).global_position).length() < 200 
		and i.mouse_enter == true): 
			i.get_child(0).set_texture(texture_trup)
			_Click_on_inventory(i)
		else:
			i.get_child(0).set_texture(texture_JIV)
		

func pick():
	item_count += 1
	print(item_count)

