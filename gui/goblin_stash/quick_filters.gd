class_name QuickFiltersGUI
extends Control

signal quick_filter_changed(quick_filter: ItemSearchQuery.QuickFilter, new_values: Array[int])

@onready var _quick_type: VBoxContainer = %QuickType
@onready var _quick_rarity: VBoxContainer = %QuickRarity
@onready var _quick_property: VBoxContainer = %QuickProperty
@onready var _quick_tier: VBoxContainer = %QuickTier


func _ready() -> void:
	for button: Button in _quick_type.get_children():
		button.pressed.connect(_update_type_filter)
	for button: Button in _quick_rarity.get_children():
		button.pressed.connect(_update_rarity_filter)
	for button: Button in _quick_property.get_children():
		button.pressed.connect(_update_property_filter)
	for button: Button in _quick_tier.get_children():
		button.pressed.connect(_update_tier_filter)


func _update_type_filter() -> void:
	quick_filter_changed.emit(ItemSearchQuery.QuickFilter.TYPE, _which_buttons_are_pressed(_quick_type))


func _update_rarity_filter() -> void:
	quick_filter_changed.emit(ItemSearchQuery.QuickFilter.RARITY, _which_buttons_are_pressed(_quick_rarity))


func _update_property_filter() -> void:
	quick_filter_changed.emit(ItemSearchQuery.QuickFilter.PROPERTY, _which_buttons_are_pressed(_quick_property))


func _update_tier_filter() -> void:
	quick_filter_changed.emit(ItemSearchQuery.QuickFilter.TIER, _which_buttons_are_pressed(_quick_tier))


func _which_buttons_are_pressed(button_container: Control) -> Array[int]:
	var pressed_buttons: Array[int]
	for index: int in button_container.get_child_count():
		if button_container.get_child(index).button_pressed:
			pressed_buttons.append(index)
	return pressed_buttons
