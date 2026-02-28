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

const SETTINGS := {
	# Global
	"instant_search": {"section": GLOBAL_SECTION, "default": true},
	"show_goblin_tooltips": {"section": GLOBAL_SECTION, "default": true},
	"show_pd2_tooltips": {"section": GLOBAL_SECTION, "default": true},
	"max_backups": {"section": GLOBAL_SECTION, "default": 5, "min": 0, "max": 10},
	"background_color": {"section": GLOBAL_SECTION, "default": Color("#4f4770")},

	# PD2
	"pd2_folder": {"section": PD2_SECTION, "default": "C:/Program Files (x86)/Diablo II/Save"},
	"pd2_stash_page": {"section": PD2_SECTION, "default": 9, "min": 1, "max": 9},
	"auto_retrieve": {"section": PD2_SECTION, "default": false},
	"hardcore_shared_stash": {"section": PD2_SECTION, "default": false},
	"load_characters": {"section": PD2_SECTION, "default": true},
}

var debug_mode: bool
# Setting vars
var max_backups: int
var instant_search: bool
var show_goblin_tooltips: bool
var show_pd2_tooltips: bool
var background_color: Color

var pd2_folder: String
var hardcore_shared_stash: bool
var load_characters: bool
var pd2_stash_page: int
var auto_retrieve: bool

var _config_file := ConfigFile.new()


func _init() -> void:
	for key: String in SETTINGS:
		set(key, SETTINGS[key].default)


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
	if SETTINGS.has(setting):
		set(setting, value)
		save_config()
		setting_changed.emit(value, setting)


func save_config() -> void:
	_config_file.clear()
	
	for key: String in SETTINGS:
		var section: String = SETTINGS[key].section
		var value: Variant = get(key)
		if value == null:
			value = SETTINGS[key].default
		_config_file.set_value(section, key, value)
		
	_config_file.save(CONFIG_FILEPATH)
	config_saved.emit()


func load_config() -> void:
	for key: String in SETTINGS:
		var params: Dictionary = SETTINGS[key]
		var section: String = params.section
		var default_value: Variant = params.default
		var value = _config_file.get_value(section, key, default_value)
		if params.get(min) and params.get(max):
			value = clampi(value, params.min, params.max)
		set(key, value)
		
	config_loaded.emit()
