extends PanelContainer

@onready var reload_timer: Timer = %ReloadTimer

var _pd2_save: PD2SaveFile


func _ready() -> void:
	hide()
	StashRegistry.stash_registered.connect(_start_monitoring_changes)
	reload_timer.timeout.connect(_check_for_changes)


func _start_monitoring_changes(stash: StashRegistry.StashType) -> void:
	if stash != StashRegistry.StashType.PD2_SHARED:
		return
	hide()
	_pd2_save = StashRegistry.get_save_file(StashRegistry.StashType.PD2_SHARED)
	reload_timer.start()


func _check_for_changes() -> void:
	if _pd2_save.file_has_changed_since_load():
		show()
	else:
		reload_timer.start()
