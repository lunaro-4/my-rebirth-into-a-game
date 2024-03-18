extends Node

@onready var Musica = $"../AudioStreamPlayer"
@onready var Musica_2 = $"../AudioStreamPlayer2"
@onready var Fon_musica = $"../AudioStreamPlayer3"
@onready var pause_menu = $"../Camera2D/PauseMenuScene"
@onready var dialog = $"../Camera2D/TestingDiaolog"

var game_paused: bool = false
var music: bool = false
var menu: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_fon_2_music_on_off()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Esc_Button"):
		_on_paused()
		_boss_music_on_off()
		_pause_menu_on_off()
	if Input.is_action_just_pressed("Enter_Button"):
		_on_paused()
		_fon_music_on_off()
		_dialog_menu_on_of()
	pass
	
func _on_paused():
	game_paused = !game_paused
	if game_paused == true:
		get_tree().paused = true
	else:
		get_tree().paused = false
		
func _boss_music_on_off():
	music = !music
	if music == true:
		Musica.play()
	else:
		Musica.stop()
	pass

func _fon_music_on_off():
	music = !music
	if music == true:
		Musica_2.play()
	else:
		Musica_2.stop()
	pass
	
func _fon_2_music_on_off():
	if music == false:
		Fon_musica.play()
	else:
		Fon_musica.stop()
	pass
	
func _pause_menu_on_off():
	menu = !menu
	if menu == true:
		pause_menu.show()
	else:
		pause_menu.hide()
		
func _dialog_menu_on_of():
	menu = !menu
	if menu == true:
		dialog.show()
	else:
		dialog.hide()
