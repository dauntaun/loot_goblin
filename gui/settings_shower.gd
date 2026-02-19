extends CenterContainer

@onready var show_settings: Button = %SettingsView
@onready var close_settings: Button = %CloseSettings
@onready var stash_loader: FileDialog = %StashLoader
@onready var stash_saver_pd2: FileDialog = %StashSaverPD2
@onready var stash_saver_goblin: FileDialog = %StashSaverGoblin


func _ready() -> void:
	hide()
	show_settings.pressed.connect(func(): show())
	close_settings.pressed.connect(hide_settings)
	stash_loader.file_selected.connect(hide_settings.unbind(1))
	stash_saver_pd2.file_selected.connect(hide_settings.unbind(1))
	stash_saver_goblin.file_selected.connect(hide_settings.unbind(1))


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left") or event.is_action_pressed("mouse_right"):
		hide_settings()


func hide_settings() -> void:
	hide()
	show_settings.button_pressed = false
