class_name GoblinSettingsGUI
extends Control

const FILE_FONT = preload("uid://cen8snwgwauy1")

# Exposed for main
@onready var plugy_importer: PlugyImporter = %PlugyImporter
@onready var load_stash_button: Button = %LoadStashButton
@onready var save_pd2_button: Button = %SavePD2Button
@onready var save_goblin_button: Button = %SaveGoblinButton
@onready var reset_goblin_button: Button = %ResetStashButton
@onready var open_backups_button: Button = %OpenBackups

# Item list
@onready var _settings_list: ItemList = %SettingsList
@onready var _settings_tabs: TabContainer = %SettingsTabs
# Global settings
@onready var _version_label: Label = %VersionLabel
@onready var _reset_goblin_debug: Control = %ResetGoblinDebug
@onready var _choose_instant_search: CheckBox = %InstantSearch
@onready var _choose_goblin_tooltips: CheckBox = %StashTooltips
@onready var _choose_pd2_tooltips: CheckBox = %PD2Tooltips
@onready var _choose_ilvl_tooltips: CheckBox = %IlvlTooltips
@onready var _choose_character_level: SpinBox = %CharacterLevel
@onready var _choose_max_backups: SpinBox = %BackupNumber
@onready var _restore_background_color_button: Button = %UndoColor
@onready var _choose_background_color: ColorPickerButton = %ChooseColor
# PD2 Settings
@onready var _pd2_save_folder_picker: FileDialog = %DefaultPD2StashPicker
@onready var _loaded_pd2_files: GridContainer = %LoadedPD2Files

@onready var _choose_pd2_save_folder: Button = %ChooseDefaultFolder
@onready var _default_folder_line: LineEdit = %DefaultFolderLine
@onready var _choose_default_stash_page: SpinBox = %DefaultStashPage
@onready var _choose_auto_retrieve: CheckBox = %AutoRetrieve
@onready var _choose_hardcore: OptionButton = %HardcoreSelect
@onready var _choose_load_characters: CheckBox = %LoadCharacters

# Updated via signals
@onready var _loaded_goblin_save_file_label: LineEdit = %LoadedGoblinLabel
@onready var _loaded_pd2_save_file_label: LineEdit = %LoadedPD2Label


func _ready() -> void:
	for child: Node in _loaded_pd2_files.get_children():
		child.queue_free()
	_version_label.text = "v" + GlobalSettings.version
	_reset_goblin_debug.visible = GlobalSettings.debug_mode
	sync_controls_with_settings()
	# Item list
	_settings_list.item_selected.connect(func(index: int): _settings_tabs.current_tab = index)
	# Unsaved changes
	CommandQueue.command_queued.connect(_disable_option_buttons)
	CommandQueue.queue_committed.connect(_enable_option_buttons)
	CommandQueue.queue_undone.connect(_enable_option_buttons)
	# Connect to global settings
	_choose_instant_search.toggled.connect(GlobalSettings.update_setting.bind("instant_search"))
	_choose_goblin_tooltips.toggled.connect(GlobalSettings.update_setting.bind("show_goblin_tooltips"))
	_choose_pd2_tooltips.toggled.connect(GlobalSettings.update_setting.bind("show_pd2_tooltips"))
	_choose_ilvl_tooltips.toggled.connect(GlobalSettings.update_setting.bind("show_ilvl_in_tooltips"))
	_choose_character_level.value_changed.connect(GlobalSettings.update_setting.bind("character_level"))
	_choose_max_backups.value_changed.connect(GlobalSettings.update_setting.bind("max_backups"))
	_choose_background_color.color_changed.connect(GlobalSettings.update_setting.bind("background_color"))
	_restore_background_color_button.pressed.connect(_restore_background_color)
	
	_choose_pd2_save_folder.pressed.connect(_pd2_save_folder_picker.popup)
	_pd2_save_folder_picker.dir_selected.connect(func(dir: String) -> void:
		GlobalSettings.update_setting(dir, "pd2_folder")
		_default_folder_line.text = dir)
	_choose_default_stash_page.value_changed.connect(GlobalSettings.update_setting.bind("pd2_stash_page"))
	_choose_auto_retrieve.toggled.connect(GlobalSettings.update_setting.bind("auto_retrieve"))
	_choose_hardcore.item_selected.connect(GlobalSettings.update_setting.bind("hardcore_shared_stash"))
	_choose_load_characters.toggled.connect(GlobalSettings.update_setting.bind("load_characters"))
	# Connect to StashRegistry
	StashRegistry.goblin_registered.connect(func() -> void:
		_loaded_goblin_save_file_label.text = StashRegistry.get_goblin_save_file().load_path.get_file())
	StashRegistry.pd2_shared_registered.connect(func() -> void:
		_loaded_pd2_save_file_label.text = StashRegistry.get_pd2_shared_save_file().load_path.get_file()
		save_pd2_button.disabled = false)
	StashRegistry.characters_registered.connect(_show_character_files)


func _restore_background_color() -> void:
	GlobalSettings.update_setting(GlobalSettings.DEFAULT_BACKGROUND_COLOR , "background_color")
	_choose_background_color.color = GlobalSettings.DEFAULT_BACKGROUND_COLOR


func _disable_option_buttons() -> void:
	_choose_hardcore.disabled = true
	reset_goblin_button.disabled = true
	save_goblin_button.disabled = true
	save_pd2_button.disabled = true
	load_stash_button.disabled = true


func _enable_option_buttons() -> void:
	_choose_hardcore.disabled = false
	reset_goblin_button.disabled = false
	save_goblin_button.disabled = false
	save_pd2_button.disabled = false
	load_stash_button.disabled = false


func _show_character_files() -> void:
	for child: Node in _loaded_pd2_files.get_children():
		child.queue_free()
	
	var character_files := StashRegistry.get_character_files()
	
	for file: D2CharacterSaveFile in character_files:
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = file.load_path.get_file()
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
		label.add_theme_font_override("font", FILE_FONT)
		_loaded_pd2_files.add_child(label)


func sync_controls_with_settings() -> void:
	_choose_instant_search.button_pressed = GlobalSettings.instant_search
	_choose_goblin_tooltips.button_pressed = GlobalSettings.show_goblin_tooltips
	_choose_pd2_tooltips.button_pressed = GlobalSettings.show_pd2_tooltips
	_choose_ilvl_tooltips.button_pressed = GlobalSettings.show_ilvl_in_tooltips
	_choose_character_level.value = GlobalSettings.character_level
	_choose_max_backups.value = GlobalSettings.max_backups
	_choose_background_color.color = GlobalSettings.background_color
	
	_default_folder_line.text = GlobalSettings.pd2_folder
	_choose_default_stash_page.value = GlobalSettings.pd2_stash_page
	_choose_auto_retrieve.button_pressed = GlobalSettings.auto_retrieve
	_choose_hardcore.selected = GlobalSettings.hardcore_shared_stash
	_choose_load_characters.button_pressed = GlobalSettings.load_characters
