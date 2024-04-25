extends Node

var objects_inventory : LevelObjectsInventory

var soul_inventory : SoulsInventory

const SAVE_FILE_LOCATION = "user://player_save/save.sav"

# var dir_access = DirAccess.new.call()


 
func load_player_state() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_LOCATION):
		return false
	var save_file = FileAccess.open(SAVE_FILE_LOCATION, FileAccess.WRITE)
	objects_inventory = save_file.get_var()
	soul_inventory = save_file.get_var()
	save_file.close()
	return true

func save_player_state():
	if DirAccess.dir_exists_absolute("user://player_save"):
		DirAccess.make_dir_absolute("user://player_save")
	var save_file = FileAccess.open(SAVE_FILE_LOCATION, FileAccess.WRITE)
	save_file.store_var(objects_inventory)
	save_file.store_var(soul_inventory)
	save_file.close()
