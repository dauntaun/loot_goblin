extends Control

@onready var settings_gui: GoblinSettingsGUI = %Settings
@onready var background_color: ColorRect = %BackgroundColor

@onready var _save_transfers_button: TransferChangesTrackerGUI = %SaveChanges
@onready var _cancel_transfers_button: Button = %CancelChanges

@onready var _reload_button: Button = %ReloadButton

@onready var _stash_loader: FileDialog = %StashLoader
@onready var _pd2_stash_saver: FileDialog = %StashSaverPD2
@onready var _goblin_stash_saver: FileDialog = %StashSaverGoblin


func _ready():
	DisplayServer.window_set_min_size(Vector2i(1050, 550))
	get_window().title = "Loot Goblin" + " " + GlobalSettings.version
	background_color.color = GlobalSettings.background_color
	# Init Goblin save
	var sc_filepath := GlobalSettings.get_sc_goblin_stash_path()
	if not FileAccess.file_exists(sc_filepath):
		var init_goblin := GoblinSaveFile.new()
		init_goblin.save_file(sc_filepath)
	var hc_filepath := GlobalSettings.get_hc_goblin_stash_path()
	if not FileAccess.file_exists(hc_filepath):
		var init_goblin := GoblinSaveFile.new()
		init_goblin.save_file(hc_filepath)
	
	# Init Stashes
	var goblin_filepath := GlobalSettings.get_current_goblin_stash_path()
	_init_goblin_stash_file(goblin_filepath)
	_init_pd2_folder(GlobalSettings.get_pd2_folder())
	StashRegistry.complete_registration()
	ItemSelection.set_destination_page_index(GlobalSettings.pd2_stash_page)
	if GlobalSettings.auto_retrieve:
		ItemSelection.store_active_page()
	
	# Connections
	GlobalSettings.setting_changed.connect(_on_setting_changed)
	_save_transfers_button.pressed.connect(_save_all_transfers)
	_cancel_transfers_button.pressed.connect(_cancel_all_transfers)
	settings_gui.open_backups_button.pressed.connect(func(): OS.shell_open(OS.get_user_data_dir()))
	settings_gui.plugy_importer.import_plugy_requested.connect(_import_plugy_items_to_goblin_stash)
	_reload_button.pressed.connect(_reload_loaded_save_files)
	settings_gui.load_stash_button.pressed.connect(_stash_loader.popup)
	settings_gui.reset_goblin_button.pressed.connect(_reset_goblin_stash_file)
	_stash_loader.file_selected.connect(_init_stash_file)
	_pd2_stash_saver.file_selected.connect(_on_pd2_save_file_selected)
	_goblin_stash_saver.file_selected.connect(_on_goblin_save_file_selected)
	settings_gui.save_pd2_button.pressed.connect(func():
		_pd2_stash_saver.get_line_edit().text = "pd2_shared.stash"
		_pd2_stash_saver.popup())
	settings_gui.save_goblin_button.pressed.connect(func():
		_goblin_stash_saver.get_line_edit().text = "goblin_stash.gstash"
		_goblin_stash_saver.popup())

# Save
func _save_all_transfers() -> void:
	var saves := CommandQueue.get_involved_save_files()
	# Check access
	for save: BasicSaveFile in saves:
		if save.file_has_changed_since_load():
			OS.alert("The save file has been accessed or modified by Diablo II or another process. Reload Loot Goblin to prevent desync.", "Warning")
			_save_transfers_button.show_warning()
			return
	# Save backup
	for save: BasicSaveFile in saves:
		_backup_save(save)
	# Commit data and check integrity
	CommandQueue.commit_queue()
	if not CommandQueue.is_command_queue_clear():
		_save_transfers_button.show_warning()
		OS.alert("Something went wrong when transferring items. Reload Loot Goblin", "Error")
		return
	ItemSelection.clear_selection()
	_save_transfers_button.clear_save_button()
	# Save
	for save: BasicSaveFile in saves:
		save.save_file(save.load_path)


func _cancel_all_transfers() -> void:
	CommandQueue.undo_queue()
	_save_transfers_button.clear_save_button()


func _on_pd2_save_file_selected(path: String) -> void: # Manual save
	var pd2_save := StashRegistry.get_pd2_shared_save_file()
	pd2_save.save_file(path)


func _on_goblin_save_file_selected(path: String) -> void: # Manual save
	var goblin_save := StashRegistry.get_goblin_save_file()
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
	if GlobalSettings.load_characters:
		var characters: Array[D2CharacterSaveFile]
		for file: String in character_files:
			var path := dir.path_join(file)
			var pd2_char := D2CharacterSaveFile.new(path)
			if not pd2_char.load_successful:
				push_error("Could not open character stash")
				OS.alert("Could not open " + pd2_char.load_path.get_file(), "Error")
				continue
			if not GlobalSettings.hardcore_shared_stash == pd2_char.is_hardcore:
				continue
			characters.append(pd2_char)
		
		StashRegistry.register_character_save_files(characters)


# When user selects a single file
func _init_stash_file(path: String) -> void:
	print("loading file " + path)
	if path.ends_with(".gstash"):
		for stash_id: int in StashRegistry.get_goblin_collection_ids():
			ItemRegistry.unregister_items_from_stash(stash_id)
		_init_goblin_stash_file(path)
		StashRegistry.complete_registration()
	elif path.ends_with(".d2s"):
		for stash_id: int in StashRegistry.get_all_character_stash_ids():
			ItemRegistry.unregister_items_from_stash(stash_id)
		_init_pd2_character_file(path)
		StashRegistry.complete_registration()
	elif path.ends_with(".stash"):
		var stash_id := StashRegistry.get_pd2_shared_stash_id()
		ItemRegistry.unregister_items_from_stash(stash_id)
		_init_pd2_shared_stash_file(path)
		StashRegistry.complete_registration()


func _init_pd2_character_file(path: String) -> void:
	var pd2_char := D2CharacterSaveFile.new(path)
	if not pd2_char.load_successful:
		push_error("Could not open character stash")
		OS.alert("Could not open " + pd2_char.load_path.get_file(), "Error")
		return
	StashRegistry.register_character_save_files([pd2_char])


func _init_pd2_shared_stash_file(path: String) -> void:
	var save_file := PD2SaveFile.new(path)
	if not save_file.load_successful:
		push_error("Could not open PD2 stash")
		OS.alert("Could not open " + save_file.load_path.get_file(), "Error")
		return
	var pd2_pages := save_file.item_list.get_pd2pages()
	StashRegistry.register_pd2_shared_save(save_file)


func _init_goblin_stash_file(path: String) -> void:
	var save_file := GoblinSaveFile.new(path)
	if not save_file.load_successful:
		push_error("Could not open Goblin stash")
		OS.alert("Could not open " + save_file.load_path.get_file(), "Error")
		return
	StashRegistry.register_goblin_save(save_file)


func _reset_goblin_stash_file() -> void:
	ItemSelection.clear_goblin_stash()


func _on_setting_changed(value: Variant, setting: String) -> void:
	match setting:
		"pd2_folder":
			if not StashRegistry.get_pd2_shared_save_file():
				_init_pd2_folder(value)
				StashRegistry.complete_registration()
		"hardcore_shared_stash":
			if CommandQueue.is_command_queue_clear():
				ItemSelection.clear_destination()
				StashRegistry.unregister_all_stashes()
				ItemRegistry.unregister_all_items()
				_init_pd2_folder(GlobalSettings.get_pd2_folder())
				var goblin_stash_path := GlobalSettings.get_current_goblin_stash_path()
				_init_goblin_stash_file(goblin_stash_path)
				StashRegistry.complete_registration()
		"background_color":
			background_color.color = GlobalSettings.background_color


func _import_plugy_items_to_goblin_stash(plugy_files: Array[PlugySaveFile]) -> void:
	var item_lists: Array[D2ItemList]
	for stash: PlugySaveFile in plugy_files:
		item_lists.append_array(stash.get_all_item_lists())
	ItemSelection.import_plugy_items(item_lists)


func _reload_loaded_save_files() -> void:
	var goblin_save := StashRegistry.get_goblin_save_file()
	CommandQueue.undo_queue()
	ItemSelection.clear_destination()
	ItemSelection.clear_selection()
	ItemRegistry.unregister_all_items()
	StashRegistry.unregister_all_stashes()
	if goblin_save:
		_init_goblin_stash_file(goblin_save.load_path)
	_init_pd2_folder(GlobalSettings.get_pd2_folder())
	StashRegistry.complete_registration()
	_save_transfers_button.hide_warning()
	if GlobalSettings.auto_retrieve:
		ItemSelection.store_active_page()
