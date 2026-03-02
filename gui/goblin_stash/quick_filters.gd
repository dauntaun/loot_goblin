class_name QuickFiltersGUI
extends Control

signal quick_filter_changed(quick_filter: String, values: Array[int])
signal quick_filter_reset

@export var filters: Dictionary[String, Control]
@export var filter_titles: Dictionary[String, Control]
@export var reset_button: Button

var _active_filter_count: Dictionary[String, int]


func _ready() -> void:
	if reset_button:
		reset_button.hide()
		reset_button.pressed.connect(_reset_all_filters)
	for filter: String in filters:
		var button_container := filters[filter]
		for button: Button in button_container.get_children():
			button.pressed.connect(_update_filter.bind(filter))


func _update_filter(filter: String) -> void:
	var values := _which_buttons_are_pressed(filters[filter])
	_active_filter_count[filter] = values.size()
	if reset_button:
		var filter_count := _get_active_filter_count()
		if filter_count == 0:
			reset_button.hide()
		else:
			reset_button.show()
			reset_button.text = "Reset (%d filters)" % filter_count
	quick_filter_changed.emit(filter, values)


func _which_buttons_are_pressed(button_container: Control) -> Array[int]:
	var pressed_buttons: Array[int]
	for index: int in button_container.get_child_count():
		if button_container.get_child(index).button_pressed:
			pressed_buttons.append(index)
	return pressed_buttons


func _get_active_filter_count() -> int:
	var count := 0
	for filter_count: int in _active_filter_count.values():
		count += filter_count
	return count


func _reset_all_filters() -> void:
	for button_container: Control in filters.values():
		for button: Button in button_container.get_children():
			button.set_pressed_no_signal(false)
	quick_filter_reset.emit()
