@tool
class_name TabSwitcher
extends Control

signal tab_switched(new_tab: int)

@export var switch_buttons: Array[Button]
@export var tab_container: TabContainer


func _ready() -> void:
	for i: int in switch_buttons.size():
		var button := switch_buttons[i]
		button.toggled.connect(_switch_tab_to_index.bind(i))
	_sync_tab_to_button(tab_container.current_tab)
	tab_container.tab_changed.connect(_sync_tab_to_button)


func _switch_tab_to_index(_toggled: bool, index: int) -> void:
	tab_container.current_tab = index
	tab_switched.emit(index)


func _sync_tab_to_button(tab: int) -> void:
	for i: int in switch_buttons.size():
		switch_buttons[i].set_pressed_no_signal(i == tab)
