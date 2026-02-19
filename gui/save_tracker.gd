class_name TransferChangesTrackerGUI
extends Button

const TransferPanel = preload("res://gui/transfer_history_panel.gd")
const TRANSFER_PANEL_SCENE = preload("res://gui/transfer_history_panel.tscn")

var _saving_disabled: bool
var _transfer_panel: TransferPanel

@onready var _cancel_button: Button = %CancelChanges


func _ready() -> void:
	var panel := TRANSFER_PANEL_SCENE.instantiate()
	_transfer_panel = panel
	_transfer_panel.hide()
	_transfer_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	_transfer_panel.top_level = true
	add_child(_transfer_panel)
	
	ItemSelection.items_transferred.connect(_update_command_labels.unbind(2))
	ItemSelection.stash_cleared.connect(_update_command_labels)
	ItemSelection.plugy_imported.connect(_update_command_labels)
	CommandQueue.queue_undone.connect(_update_command_labels)
	mouse_entered.connect(_show_changes)
	mouse_exited.connect(_hide_changes)
	#_cancel_button.mouse_entered.connect(_show_changes)
	#_cancel_button.mouse_exited.connect(_hide_changes)
	gui_input.connect(_forward_scroll_events)


func _forward_scroll_events(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_transfer_panel.scroll_vertical -= 10
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_transfer_panel.scroll_vertical += 10


func _update_command_labels() -> void:
	var command_queue := CommandQueue.get_command_queue()
	disabled = _saving_disabled or command_queue.is_empty()
	_cancel_button.disabled = disabled
	_transfer_panel.update_command_labels(command_queue)


func _show_changes() -> void:
	if CommandQueue.is_command_queue_clear():
		return
	_transfer_panel.show()
	var screen_limits := get_viewport_rect().size
	_transfer_panel.global_position.x = clamp(global_position.x, 0, screen_limits.x - _transfer_panel.size.x)
	_transfer_panel.global_position.y = global_position.y  - _transfer_panel.size.y


func _hide_changes() -> void:
	_transfer_panel.hide()


func clear_save_button() -> void:
	disabled = true
	_cancel_button.disabled = true
	_transfer_panel.clear_command_labels()
	_hide_changes()


func show_warning() -> void:
	text = "Save disabled"
	_saving_disabled = true
	disabled = true


func hide_warning() -> void:
	text = "Save"
	_saving_disabled = false
