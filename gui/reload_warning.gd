extends Control

const WARNING_STYLEBOX = preload("uid://bvc7dxmalmboo")

@onready var reload_timer: Timer = %ReloadTimer
@onready var reload_warning: PanelContainer = %ReloadWarning

var _pd2_save: PD2SaveFile
var _empty_stylebox := StyleBoxEmpty.new()


func _ready() -> void:
	reload_warning.hide()
	add_theme_stylebox_override("panel", _empty_stylebox)
	StashRegistry.stash_registered.connect(_start_monitoring_changes)
	reload_timer.timeout.connect(_check_for_changes)


func _start_monitoring_changes(stash: StashRegistry.StashType) -> void:
	if stash != StashRegistry.StashType.PD2_SHARED:
		return
	add_theme_stylebox_override("panel", _empty_stylebox)
	reload_warning.hide()
	_pd2_save = StashRegistry.get_save_file(StashRegistry.StashType.PD2_SHARED)
	reload_timer.start()


func _check_for_changes() -> void:
	if _pd2_save.file_has_changed_since_load():
		add_theme_stylebox_override("panel", WARNING_STYLEBOX)
		reload_warning.show()
	else:
		reload_timer.start()
