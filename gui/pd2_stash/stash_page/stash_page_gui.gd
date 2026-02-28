@tool
class_name StashPageGUI
extends Control

signal item_selected(item: D2Item)

const ITEM_RECT_SCENE = preload("uid://dmcf3j2822imo")
const GRID_PIXEL_SIZE := 40

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


func _ready() -> void:
	pass
	#var test_item := D2Item.new()
	#test_item.x_coord = 9
	#test_item.y_coord = 3
	#test_item.inv_height = 2
	#test_item.inv_width = 1
	#add_item_rect(test_item)


func _draw() -> void:
	if grid_width <= 0 or grid_height <= 0:
		return

	var cell_size: Vector2 = size / Vector2(grid_width, grid_height)

	var line_width := 2
	var line_color := Color("#545454ff")
	var bg_color := Color("#1d1d1dff")

	# Draw background
	draw_rect(Rect2(Vector2.ZERO, size), bg_color)
	
	# Draw borders
	draw_rect(Rect2(Vector2(line_width/2, line_width/2), size - Vector2(line_width, line_width)), line_color, false, line_width)
	
	# Vertical lines
	for x: int in range(1, grid_width):
		var xpos := roundi(x * cell_size.x)
		draw_line(
			Vector2(xpos, 0),
			Vector2(xpos, size.y),
			line_color,
			line_width
		)

	# Horizontal lines
	for y: int in range(1, grid_height):
		var ypos := roundi(y * cell_size.y)
		draw_line(
			Vector2(0, ypos),
			Vector2(size.x, ypos),
			line_color,
			line_width
		)


func _remake_grid() -> void:
	custom_minimum_size = Vector2(grid_width * GRID_PIXEL_SIZE, grid_height * GRID_PIXEL_SIZE)


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
	
	item_rect.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	item_rect.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(item_rect)
	item_rect.custom_minimum_size = Vector2(item.inv_width, item.inv_height) * 40
	item_rect.size = item_rect.custom_minimum_size
	item_rect.position = item.get_coord() * GRID_PIXEL_SIZE
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
