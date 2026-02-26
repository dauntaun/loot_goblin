class_name TabSwitcher
extends Control

signal tab_switched(new_tab: int)

enum ButtonMode {MULTIPLE, SINGLE}

@export var switch_buttons: Array[Button]
@export var tab_container: TabContainer
@export var button_mode: ButtonMode


func _ready() -> void:
	for i: int in switch_buttons.size():
		var button := switch_buttons[i]
		button.toggled.connect(_switch_tab_to_index.bind(i))


func _switch_tab_to_index(toggled: bool, index: int) -> void:
	if button_mode == ButtonMode.MULTIPLE:
		tab_container.current_tab = index
	else:
		tab_container.current_tab = toggled
	tab_switched.emit(index)
