@tool
class_name StashPageGUI
extends Control

signal item_selected(item: D2Item)

const ITEM_RECT_SCENE = preload("uid://dmcf3j2822imo")
const GRID_PIXEL_SIZE := 40
const GRID_INNER_MARGINS: int = 4

@export_range(1, 10) var grid_width: int = 10: 
	set(new):
		grid_width = new
		_remake_grid()
@export_range(1, 15) var grid_height: int = 15:
	set(new):
		grid_height = new
		_remake_grid()

var _item_rect_mapping: Dictionary[D2Item, ItemRect]
var _prev_selected_item: D2Item
var _initialized := false

@onready var _texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	pass
	#var test_item := D2Item.new()
	#test_item.x_coord = 1
	#test_item.y_coord = 0
	#test_item.inv_height = 4
	#test_item.inv_width = 2
	#add_item_rect(test_item)


func _remake_grid() -> void:
	custom_minimum_size = Vector2(grid_width * GRID_PIXEL_SIZE + 4, grid_height * GRID_PIXEL_SIZE + 4)


func init_page(init_items: Array[D2Item]) -> void:
	if _initialized:
		_reset()
	for item: D2Item in init_items:
		add_item_rect(item)
	_initialized = true


func _reset() -> void:
	for item: D2Item in _item_rect_mapping:
		_item_rect_mapping[item].queue_free()
	_item_rect_mapping.clear()


func add_item_rect(item: D2Item) -> void:
	var item_rect: ItemRect = ITEM_RECT_SCENE.instantiate()
	item_rect.item_selected.connect(_on_item_selected)
	# Setup
	
	item_rect.position = item.get_coord() * GRID_PIXEL_SIZE
	_texture_rect.add_child(item_rect)
	item_rect.init_rect(item)
	_item_rect_mapping[item] = item_rect


func get_item_at_mouse_pos(pos: Vector2) -> D2Item:
	var item_rect := get_item_rect_at_mouse_pos(pos)
	if item_rect == null:
		return null
	return _item_rect_mapping.find_key(item_rect)


func get_item_rect_at_mouse_pos(pos: Vector2) -> ItemRect:
	pos = get_global_mouse_position()
	for item_rect: ItemRect in _item_rect_mapping.values():
		if item_rect.get_global_rect().has_point(pos):
			return item_rect
	return null


func select_item(item: D2Item) -> void:
	_item_rect_mapping[item].select()


func remove_item(item: D2Item) -> void:
	if not _item_rect_mapping.has(item):
		push_error("Trying to remove a non-existing item in grid")
		return
	_item_rect_mapping[item].queue_free()
	_item_rect_mapping.erase(item)


func _on_item_selected(item: D2Item) -> void:
	_prev_selected_item = item
	item_selected.emit(item)


func restore_last_selection() -> void:
	if _item_rect_mapping.has(_prev_selected_item):
		_item_rect_mapping[_prev_selected_item].item_selected.emit(_prev_selected_item)
