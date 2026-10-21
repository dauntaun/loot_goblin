class_name PD2GUI
extends Control

var _selected_item_rects: Array[ItemRect]
var _sort_menu: PopupMenu
var _sort_grid: StashPageGUI

@onready var _PD2_stash_GUI: PD2StashGUI = %PD2Stash
@onready var _PD2_character_GUI: PD2CharacterGUI = %PD2Character


func _ready() -> void:
	_PD2_stash_GUI.item_rect_clicked.connect(_on_item_rect_clicked)
	_PD2_stash_GUI.grid_right_clicked.connect(_on_grid_right_clicked)
	_PD2_character_GUI.item_rect_clicked.connect(_on_item_rect_clicked)
	_PD2_character_GUI.grid_right_clicked.connect(_on_grid_right_clicked)
	# Setup right click to sort
	_sort_menu = PopupMenu.new()
	_sort_menu.add_item("Select All", 99)
	add_child(_sort_menu)
	_sort_menu.id_pressed.connect(_on_sort_menu_picked)


func _on_item_rect_clicked(item_rect: ItemRect) -> void:
	if Input.is_key_pressed(KEY_CTRL):
		if item_rect in _selected_item_rects:
			_deselect_item(item_rect)
		else:
			_select_item(item_rect)
	else:
		clear_selection()
		_select_item(item_rect)

	_update_selection()


func _select_item(item_rect: ItemRect) -> void:
	if not is_instance_valid(item_rect):
		return

	if item_rect in _selected_item_rects:
		return

	_selected_item_rects.append(item_rect)
	item_rect.select()

	if not item_rect.tree_exited.is_connected(_on_selected_item_tree_exited):
		item_rect.tree_exited.connect(_on_selected_item_tree_exited.bind(item_rect))


func _deselect_item(item_rect: ItemRect) -> void:
	if not is_instance_valid(item_rect):
		_selected_item_rects.erase(item_rect)
		return

	_selected_item_rects.erase(item_rect)
	item_rect.deselect()


func clear_selection() -> void:
	for item_rect: ItemRect in _selected_item_rects:
		if is_instance_valid(item_rect):
			item_rect.deselect()

	_selected_item_rects.clear()


func _on_selected_item_tree_exited(item_rect: ItemRect) -> void:
	if item_rect:
		_selected_item_rects.erase(item_rect)

	_update_selection()


func _update_selection() -> void:
	var selected_items: Array[D2Item] = []

	for item_rect: ItemRect in _selected_item_rects:
		if is_instance_valid(item_rect):
			selected_items.append(item_rect._item)

	ItemSelection.set_selection(selected_items)
	
	if ItemSelection.get_destination_stash_type() in [StashRegistry.StashType.PD2_SHARED, StashRegistry.StashType.PD2_PERSONAL, StashRegistry.StashType.UNKNOWN]:
		ItemSelection.set_destination(StashRegistry.StashType.GOBLIN)


func _on_sort_menu_picked(id: int) -> void:
	if id == 99:
		clear_selection()
		for item_rect: ItemRect in _sort_grid._item_rect_mapping.values():
			item_rect.select()
		_selected_item_rects = _sort_grid._item_rect_mapping.values()
		ItemSelection.set_selection(_sort_grid._item_rect_mapping.keys())
		
		if ItemSelection.get_destination_stash_type() in [StashRegistry.StashType.PD2_SHARED, StashRegistry.StashType.PD2_PERSONAL, StashRegistry.StashType.UNKNOWN]:
			ItemSelection.set_destination(StashRegistry.StashType.GOBLIN)


func _on_grid_right_clicked(grid: StashPageGUI) -> void:
	_sort_grid = grid
	_sort_menu.position = get_global_mouse_position()
	_sort_menu.popup()
