class_name QuickFiltersGUI
extends Control

signal quick_filter_changed(quick_filter: String, values: Array[int])

@export var filters: Dictionary[String, Control]
@export var filter_titles: Dictionary[String, Control]


func _ready() -> void:
	for filter: String in filters:
		var button_container := filters[filter]
		for button: Button in button_container.get_children():
			button.pressed.connect(_update_filter.bind(filter))


func _update_filter(filter: String) -> void:
	quick_filter_changed.emit(filter, _which_buttons_are_pressed(filters[filter]))


func _which_buttons_are_pressed(button_container: Control) -> Array[int]:
	var pressed_buttons: Array[int]
	for index: int in button_container.get_child_count():
		if button_container.get_child(index).button_pressed:
			pressed_buttons.append(index)
	return pressed_buttons
