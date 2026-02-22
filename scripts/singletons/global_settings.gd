extends Node

signal setting_changed(setting: String, value: Variant)
signal config_loaded
signal config_saved

const CONFIG_FILEPATH := "user://settings.cfg"
const BACKUP_FOLDER := "user://backups"
const PD2_SECTION := "PD2 Settings"
const GLOBAL_SECTION := "Global Settings"

const SOFTCORE_SHARED_STASH_FILENAME := "pd2_shared.stash"
const HARDCORE_SHARED_STASH_FILENAME := "pd2_hc_shared.stash"
const GOBLIN_STASH_DIR := "user://"
const GOBLIN_STASH_DIR_DEBUG := "res://local_data"
const PD2_FOLDER_DIR_DEBUG := "res://local_data/test_stash/pd2"
const GOBLIN_STASH_FILENAME := "goblin_stash.gstash"
const GOBLIN_HC_STASH_FILENAME := "goblin_hc_stash.gstash"
const DEFAULT_BACKGROUND_COLOR := Color("#4f4770")

var debug_mode: bool = false
# Setting vars
var max_backups: int = 5
var instant_search: bool = true
var show_goblin_tooltips: bool = true
var show_pd2_tooltips: bool = true
var background_color: Color = Color("#4f4770")

var pd2_folder: String = "C:/Program Files (x86)/Diablo II/Save"
var hardcore_shared_stash: bool = false
var load_characters: bool = true
var pd2_stash_page: int = 9
var auto_retrieve: bool = false

var _config_file := ConfigFile.new()


func _ready() -> void:
	if FileAccess.file_exists(CONFIG_FILEPATH):
		_config_file.load(CONFIG_FILEPATH)
	else:
		save_config()
	load_config()


func get_shared_stash_path() -> String:
	var dir := PD2_FOLDER_DIR_DEBUG if GlobalSettings.debug_mode else pd2_folder
	if hardcore_shared_stash:
		dir = dir.path_join(HARDCORE_SHARED_STASH_FILENAME)
	else:
		dir = dir.path_join(SOFTCORE_SHARED_STASH_FILENAME)
	return dir


func get_pd2_folder() -> String:
	return PD2_FOLDER_DIR_DEBUG if GlobalSettings.debug_mode else pd2_folder


func get_current_goblin_stash_path() -> String:
	var dir := GOBLIN_STASH_DIR_DEBUG if GlobalSettings.debug_mode else GOBLIN_STASH_DIR
	if hardcore_shared_stash:
		return dir.path_join(GOBLIN_HC_STASH_FILENAME)
	else:
		return dir.path_join(GOBLIN_STASH_FILENAME)


func get_sc_goblin_stash_path() -> String:
	return GOBLIN_STASH_DIR.path_join(GOBLIN_STASH_FILENAME)


func get_hc_goblin_stash_path() -> String:
	return GOBLIN_STASH_DIR.path_join(GOBLIN_HC_STASH_FILENAME)


func update_setting(value: Variant, setting: String) -> void:
	match setting:
		"max_backups":
			max_backups = value
		"pd2_folder":
			pd2_folder = value
		"pd2_stash_page":
			pd2_stash_page = value
		"auto_retrieve":
			auto_retrieve = value
		"hardcore_shared_stash":
			hardcore_shared_stash = value
		"load_characters":
			load_characters = value
		"instant_search":
			instant_search = value
		"show_goblin_tooltips":
			show_goblin_tooltips = value
		"show_pd2_tooltips":
			show_pd2_tooltips = value
		"background_color":
			background_color = value
	save_config()
	setting_changed.emit(value, setting)


func save_config() -> void:
	_config_file.clear()
	_config_file.set_value(GLOBAL_SECTION, "instant_search", instant_search)
	_config_file.set_value(GLOBAL_SECTION, "show_goblin_tooltips", show_goblin_tooltips)
	_config_file.set_value(GLOBAL_SECTION, "show_pd2_tooltips", show_pd2_tooltips)
	_config_file.set_value(GLOBAL_SECTION, "max_backups", max_backups)
	_config_file.set_value(GLOBAL_SECTION, "background_color", background_color)
	
	_config_file.set_value(PD2_SECTION, "pd2_folder", pd2_folder)
	_config_file.set_value(PD2_SECTION, "pd2_stash_page", pd2_stash_page)
	_config_file.set_value(PD2_SECTION, "auto_retrieve", auto_retrieve)
	_config_file.set_value(PD2_SECTION, "hardcore_shared_stash", hardcore_shared_stash)
	_config_file.set_value(PD2_SECTION, "load_characters", load_characters)
	_config_file.save(CONFIG_FILEPATH)
	config_saved.emit()


func load_config() -> void:
	instant_search = _config_file.get_value(GLOBAL_SECTION, "instant_search", true)
	show_goblin_tooltips = _config_file.get_value(GLOBAL_SECTION, "show_goblin_tooltips", true)
	show_pd2_tooltips = _config_file.get_value(GLOBAL_SECTION, "show_pd2_tooltips", true)
	max_backups = clampi(_config_file.get_value(GLOBAL_SECTION, "max_backups", 5), 0, 10)
	background_color = _config_file.get_value(GLOBAL_SECTION, "background_color", Color("#4f4770"))
	
	pd2_folder = _config_file.get_value(PD2_SECTION, "pd2_folder", "")
	pd2_stash_page = clampi(_config_file.get_value(PD2_SECTION, "pd2_stash_page", 9), 1, 9)
	auto_retrieve = _config_file.get_value(PD2_SECTION, "auto_retrieve", false)
	hardcore_shared_stash = _config_file.get_value(PD2_SECTION, "hardcore_shared_stash", false)
	load_characters = _config_file.get_value(PD2_SECTION, "load_characters", true)
	config_loaded.emit()
