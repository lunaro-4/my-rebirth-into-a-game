extends Control

@onready var testing_pause_scene = $"../../manager"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	testing_pause_scene._on_paused()
	testing_pause_scene._boss_music_on_off()
	testing_pause_scene._pause_menu_on_off()


func _on_button_2_pressed():
	get_tree().quit()
