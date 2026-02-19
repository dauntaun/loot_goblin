class_name PlugyImporter
extends Control

signal import_plugy_requested(files: Array[PlugySaveFile])

const FILE_FONT = preload("uid://cen8snwgwauy1")

var _plugy_files: Array[PlugySaveFile]

@onready var _plugy_file_picker: FileDialog = %PlugyPicker
@onready var _plugy_folder_picker: FileDialog = %PlugyFolderPicker
@onready var _choose_file_button: Button = %ChoosePlugyStash
@onready var _choose_folder_button: Button = %ChoosePlugyFolder

@onready var _main_import_container: VBoxContainer = %PlugyImport
@onready var _plugy_files_container: GridContainer = %PlugyFiles
@onready var _total_item_count_label: Label = %PlugyItemCount
@onready var _import_plugy_button: Button = %ImportPlugy
@onready var _reset_plugy_import_button: Button = %ResetPlugy


func _ready() -> void:
	_main_import_container.hide()
	
	_choose_file_button.pressed.connect(func():
		_plugy_file_picker.current_dir = GlobalSettings.pd2_folder
		_plugy_file_picker.popup())
	_choose_folder_button.pressed.connect(func():
		_plugy_folder_picker.current_dir = GlobalSettings.pd2_folder
		_plugy_folder_picker.popup())
	_plugy_file_picker.file_selected.connect(_import_plugy_stash)
	_plugy_folder_picker.dir_selected.connect(_import_plugy_folder)
	_import_plugy_button.pressed.connect(_copy_plugy_items_to_goblin_stash)
	_reset_plugy_import_button.pressed.connect(_reset_plugy_import)
	
	CommandQueue.command_queued.connect(_disable_import)
	CommandQueue.queue_committed.connect(_enable_import)
	CommandQueue.queue_undone.connect(_enable_import)


func _disable_import() -> void:
	_choose_file_button.disabled = true
	_choose_folder_button.disabled = true
	_reset_plugy_import()


func _enable_import() -> void:
	_choose_file_button.disabled = false
	_choose_folder_button.disabled = false


func _import_plugy_stash(path: String) -> void:
	_plugy_files.clear()
	var plugy_file := PlugySaveFile.new(path)
	if not plugy_file.load_successful:
		push_error("Could not open plugy stash")
		OS.alert("Could not open " + plugy_file.load_path.get_file(), "Error")
		return
	_plugy_files.append(plugy_file)
	_plugy_files_container.get_children().map(func(x): x.queue_free())
	_add_plugy_import_labels(path, plugy_file.get_total_item_count(), plugy_file.get_page_count())
	_total_item_count_label.text = "Items found: %d" % plugy_file.get_total_item_count()
	_main_import_container.show()


func _copy_plugy_items_to_goblin_stash() -> void:
	if not _plugy_files or _plugy_files.is_empty():
		push_error("Empty plugy folder")
		return
	var selected_files: Array[PlugySaveFile]
	for i: int in _plugy_files.size():
		var checkbox := _plugy_files_container.get_child(i * 4 + 3) as CheckBox
		if checkbox.button_pressed:
			selected_files.append(_plugy_files[i])
	
	import_plugy_requested.emit(selected_files)
	_plugy_files.clear()
	_main_import_container.hide()


func _reset_plugy_import() -> void:
	_plugy_files.clear()
	_main_import_container.hide()


func _add_plugy_import_labels(path: String, item_count: int, page_count: int) -> void:
	var file_label := Label.new()
	file_label.add_theme_font_override("font", FILE_FONT)
	file_label.text = path.get_file()
	file_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_label.clip_text = true
	file_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var item_count_label := Label.new()
	item_count_label.text = str(item_count)
	item_count_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var page_count_label := item_count_label.duplicate()
	page_count_label.text = str(page_count)
	var include_checbox := CheckBox.new()
	include_checbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
	include_checbox.button_pressed = true
	_plugy_files_container.add_child(file_label)
	_plugy_files_container.add_child(item_count_label)
	_plugy_files_container.add_child(page_count_label)
	_plugy_files_container.add_child(include_checbox)


func _import_plugy_folder(dir: String) -> void:
	var files := DirAccess.get_files_at(dir)
	var valid_files: Array[String]
	for file: String in files:
		if file.ends_with(".d2x") or file.ends_with(".sss"):
			valid_files.append(file)
	if valid_files.is_empty():
		return
	_plugy_files.clear()
	var total_item_count: int = 0
	_plugy_files_container.get_children().map(func(x): x.queue_free())
	for path: String in valid_files:
		var plugy_file := PlugySaveFile.new(dir.path_join(path))
		if not plugy_file.load_successful:
			push_error("Could not open plugy stash")
			OS.alert("Could not open " + plugy_file.load_path.get_file(), "Error")
		else:
			_plugy_files.append(plugy_file)
			var item_count: int = plugy_file.get_total_item_count()
			total_item_count += item_count
			_add_plugy_import_labels(path, item_count, plugy_file.get_page_count())
	_total_item_count_label.text = "Items found: %d" % total_item_count
	_main_import_container.show()
