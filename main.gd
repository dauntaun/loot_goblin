extends Control

var goblin_save: GoblinSaveFile
var pd2_shared_save: PD2SaveFile
var pd2_character_saves: Array[D2CharacterSaveFile]

@onready var pd2_characters_gui: CharacterSelectGUI = %PD2
@onready var pd2_gui: PD2StashGUI = %PD2Stash
@onready var goblin_gui: GoblinStashGUI = %GoblinStash
@onready var settings_gui: GoblinSettingsGUI = %Settings

@onready var _save_transfers_button: TransferChangesTrackerGUI = %SaveChanges
@onready var _cancel_transfers_button: Button = %CancelChanges
@onready var _reload_button: Button = %ReloadButton
# Debug Settings
@onready var _stash_loader: FileDialog = %StashLoader
@onready var _pd2_stash_saver: FileDialog = %StashSaverPD2
@onready var _goblin_stash_saver: FileDialog = %StashSaverGoblin


func _ready():
	DisplayServer.window_set_min_size(Vector2i(1050, 550))
	settings_gui.background_color_rect.color = GlobalSettings.background_color
	# Init Goblin
	var sc_filepath := GlobalSettings.get_sc_goblin_stash_path()
	if not FileAccess.file_exists(sc_filepath):
		var init_goblin := GoblinSaveFile.new()
		init_goblin.save_file(sc_filepath)
	var hc_filepath := GlobalSettings.get_hc_goblin_stash_path()
	if not FileAccess.file_exists(hc_filepath):
		var init_goblin := GoblinSaveFile.new()
		init_goblin.save_file(hc_filepath)
	
	var goblin_filepath := GlobalSettings.get_current_goblin_stash_path()
	_init_goblin_stash_file(goblin_filepath)
	# Init PD2
	_init_pd2_folder(GlobalSettings.get_pd2_folder())
	if pd2_shared_save:
		pd2_gui.current_tab = GlobalSettings.pd2_stash_page + 1
		if GlobalSettings.auto_retrieve:
			ItemSelection.store_active_page()
	
	_save_transfers_button.pressed.connect(_save_all_transfers)
	_cancel_transfers_button.pressed.connect(_cancel_all_transfers)
	GlobalSettings.setting_changed.connect(_on_setting_changed)
	settings_gui.open_backups_button.pressed.connect(func(): OS.shell_open(OS.get_user_data_dir()))
	settings_gui.plugy_importer.import_plugy_requested.connect(_import_plugy_items_to_goblin_stash)
	# Debug
	_reload_button.pressed.connect(_reload_loaded_save_files)
	settings_gui.reset_goblin_button.pressed.connect(_reset_goblin_stash_file)
	settings_gui.save_goblin_button.pressed.connect(_save_goblin_stash_file)
	settings_gui.load_stash_button.pressed.connect(func(): _stash_loader.popup())
	settings_gui.save_pd2_button.pressed.connect(func():
		_pd2_stash_saver.get_line_edit().text = "pd2_shared.stash"
		_pd2_stash_saver.popup())
	settings_gui.save_goblin_button.pressed.connect(func():
		_goblin_stash_saver.get_line_edit().text = "goblin_stash.gstash"
		_goblin_stash_saver.popup())
	_stash_loader.file_selected.connect(_init_stash_file)
	_pd2_stash_saver.file_selected.connect(_on_pd2_save_file_selected)
	_goblin_stash_saver.file_selected.connect(_on_goblin_save_file_selected)

# Save
func _save_all_transfers() -> void:
	if pd2_shared_save.file_has_changed_since_load():
		OS.alert("The PD2 save file has been accessed or modified by Diablo II or another process. Reload Loot Goblin to prevent desync.", "Warning")
		_save_transfers_button.show_warning()
		return
	
	_backup_save(goblin_save)
	_backup_save(pd2_shared_save)
	CommandQueue.commit_queue()
	if not CommandQueue.is_command_queue_clear():
		_save_transfers_button.show_warning()
		OS.alert("Something went wrong when transferring items. Reload Loot Goblin", "Error")
		return
	ItemSelection.clear_selection()
	_save_transfers_button.clear_save_button()
	goblin_save.save_file(goblin_save.load_path)
	pd2_shared_save.save_file(pd2_shared_save.load_path)


func _cancel_all_transfers() -> void:
	CommandQueue.undo_queue()
	_save_transfers_button.clear_save_button()


func _save_goblin_stash_file() -> void: # Manual save
	goblin_save.save_file(goblin_save.load_path)


func _on_pd2_save_file_selected(path: String) -> void: # Manual save
	pd2_shared_save.save_file(path)


func _on_goblin_save_file_selected(path: String) -> void: # Manual save
	goblin_save.save_file(path)


func _backup_save(save: BasicSaveFile) -> void:
	if not DirAccess.dir_exists_absolute(GlobalSettings.BACKUP_FOLDER):
		DirAccess.make_dir_absolute(GlobalSettings.BACKUP_FOLDER)
	var files = DirAccess.get_files_at(GlobalSettings.BACKUP_FOLDER) as Array[String]
	files = files.filter(func(x: String): return x.ends_with(save.load_path.get_file()))
	files.sort()
	var diff := files.size() - GlobalSettings.max_backups
	if diff >= 0:
		for i: int in diff + 1:
			var oldest_file_path: String = files.pop_front()
			DirAccess.remove_absolute(GlobalSettings.BACKUP_FOLDER.path_join(oldest_file_path))

	var datetime_string := Time.get_datetime_string_from_system()
	datetime_string = datetime_string.replace(":", "").replace("-", "").replace("T", "_")
	var filename := datetime_string + "_" + save.load_path.get_file()
	save.save_file(GlobalSettings.BACKUP_FOLDER.path_join(filename))


func get_local_datetime_string_from_unix_time(ts: int, space: bool = false) -> String:
	var timezone := Time.get_time_zone_from_system()
	var offset := (timezone["bias"] as int) * 60 # 1min = 60s
	return Time.get_datetime_string_from_unix_time(ts + offset, space)


# When user selected a folder
func _init_pd2_folder(dir: String) -> void:
	if not DirAccess.dir_exists_absolute(dir):
		return
	var files = DirAccess.get_files_at(dir) as Array[String]
	var character_files = files.filter(func(x: String): return x.ends_with(".d2s")) as Array[String]
	var shared_stash_path := GlobalSettings.get_shared_stash_path()
	if character_files.is_empty() and not FileAccess.file_exists(shared_stash_path):
		return
	if FileAccess.file_exists(shared_stash_path):
		_init_pd2_shared_stash_file(shared_stash_path)
	pd2_character_saves.clear()
	if GlobalSettings.load_characters:
		for file: String in character_files:
			var path := dir.path_join(file)
			var pd2_char := D2CharacterSaveFile.new(path)
			if not pd2_char.load_successful:
				push_error("Could not open character stash")
				OS.alert("Could not open " + pd2_char.load_path.get_file(), "Error")
			else:
				pd2_character_saves.append(pd2_char)
	pd2_characters_gui.init_characters(pd2_character_saves)
	_show_loaded_pd2_files()


# When user selects a single file
func _init_stash_file(path: String) -> void:
	print("loading file " + path)
	if path.ends_with(".gstash"):
		_init_goblin_stash_file(path)
	elif path.ends_with(".d2s"):
		_init_pd2_character_file(path)
	elif path.ends_with(".stash"):
		_init_pd2_shared_stash_file(path)


func _init_pd2_character_file(path: String) -> void:
	pd2_character_saves.clear()
	var save_file := D2CharacterSaveFile.new(path)
	if not save_file.load_successful:
		push_error("Could not open character stash")
		OS.alert("Could not open " + save_file.load_path.get_file(), "Error")
		return
	pd2_character_saves.append(save_file)
	pd2_characters_gui.init_characters(pd2_character_saves)
	_show_loaded_pd2_files()


func _init_pd2_shared_stash_file(path: String) -> void:
	var save_file := PD2SaveFile.new(path)
	if not save_file.load_successful:
		push_error("Could not open PD2 stash")
		OS.alert("Could not open " + save_file.load_path.get_file(), "Error")
		return
	settings_gui.loaded_pd2_label.text = save_file.load_path.get_file()
	pd2_shared_save = save_file
	var pd2_pages := save_file.item_list.get_pd2pages()
	StashRegistry.register_stash(StashRegistry.StashType.PD2_SHARED, save_file.item_list, pd2_pages, save_file)
	pd2_gui.init_shared_pages(pd2_pages, save_file.materials_page)
	settings_gui.save_pd2_button.disabled = false
	_show_loaded_pd2_files()


func _init_goblin_stash_file(path: String) -> void:
	var save_file := GoblinSaveFile.new(path)
	if not save_file.load_successful:
		push_error("Could not open Goblin stash")
		OS.alert("Could not open " + save_file.load_path.get_file(), "Error")
		return
	settings_gui.loaded_goblin_label.text = save_file.load_path.get_file()
	goblin_save = save_file
	var stash_view := save_file.item_list.get_itemlist()
	StashRegistry.register_stash(StashRegistry.StashType.GOBLIN, save_file.item_list, stash_view, save_file)
	goblin_gui.init_stash(stash_view)


func _reset_goblin_stash_file() -> void:
	ItemSelection.clear_goblin_stash()


func _show_loaded_pd2_files() -> void:
	var loaded_files: Array[String]
	if pd2_shared_save:
		loaded_files.append(pd2_shared_save.load_path.get_file())
	for character: D2CharacterSaveFile in pd2_character_saves:
		loaded_files.append(character.load_path.get_file())
	settings_gui.show_loaded_pd2_files(loaded_files)


func _on_setting_changed(value: Variant, setting: String) -> void:
	match setting:
		"pd2_folder":
			if not pd2_shared_save:
				_init_pd2_folder(value)
		"hardcore_shared_stash":
			if CommandQueue.is_command_queue_clear():
				var shared_stash_path := GlobalSettings.get_shared_stash_path()
				if FileAccess.file_exists(shared_stash_path):
					_init_stash_file(shared_stash_path)
				var goblin_stash_path := GlobalSettings.get_current_goblin_stash_path()
				_init_goblin_stash_file(goblin_stash_path)
		"background_color":
			settings_gui.background_color_rect.color = GlobalSettings.background_color


func _import_plugy_items_to_goblin_stash(plugy_files: Array[PlugySaveFile]) -> void:
	var item_lists: Array[D2ItemList]
	for stash: PlugySaveFile in plugy_files:
		item_lists.append_array(stash.get_all_item_lists())
	ItemSelection.import_plugy_items(item_lists)


func _reload_loaded_save_files() -> void:
	CommandQueue.undo_queue()
	if goblin_save:
		_init_goblin_stash_file(goblin_save.load_path)
	_init_pd2_folder(GlobalSettings.pd2_folder)
	_save_transfers_button.hide_warning()
	if pd2_shared_save:
		pd2_gui.current_tab = GlobalSettings.pd2_stash_page + 1
		if GlobalSettings.auto_retrieve:
			ItemSelection.store_active_page()
