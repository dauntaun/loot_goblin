class_name StashTreeView
extends Tree

signal sort_requested(sort_key: ItemSorter.SortKey, sort_ascending: bool)
signal item_clicked(item: D2Item)

enum ColType {ITEM = 0, TYPE = 4, ETH = 1, CORRUPT = 2, SOCKETS = 3}
enum RestoreSelection {NONE, BY_INDEX, BY_ITEM}
enum RestoreFallback {NONE, FIRST_INDEX, LAST_INDEX}

const COL_NAME_MAP: Dictionary[ColType, Dictionary] = {
	ColType.ITEM: {"col_name": "Item", "sort_key": ItemSorter.SortKey.NAME},
	ColType.CORRUPT: {"col_name": "Corr", "sort_key": ItemSorter.SortKey.CORRUPT},
	ColType.TYPE: {"col_name": "Type", "sort_key": ItemSorter.SortKey.TYPE},
	ColType.ETH: {"col_name": "Eth", "sort_key": ItemSorter.SortKey.ETH},
	ColType.SOCKETS: {"col_name": "Soc", "sort_key": ItemSorter.SortKey.SOCKETS},
}
const SORT_COLUMN_HIGHLIGHT: Color = Color(0.808, 0.847, 0.922, 0.027)

var _sort_column: int = 0
var _sort_ascending: bool = true
# Selection
var _prev_selected_index: int
var _prev_selected_item: D2Item
var _item_map: Dictionary[D2Item, TreeItem]


func _ready() -> void:
	column_title_clicked.connect(_on_column_clicked)
	for col: int in COL_NAME_MAP:
		var col_name: String = COL_NAME_MAP[col].col_name
		set_column_title(col, col_name)
		set_column_expand(col, false)
		set_column_custom_minimum_width(col, get_column_width(col) + 20)
		set_column_title_alignment(col, HORIZONTAL_ALIGNMENT_CENTER)
	set_column_title_alignment(ColType.ITEM, HORIZONTAL_ALIGNMENT_CENTER)
	set_column_title_alignment(ColType.TYPE, HORIZONTAL_ALIGNMENT_LEFT)
	set_column_expand(ColType.ITEM, true)
	set_column_expand(ColType.TYPE, true)
	set_column_expand_ratio(ColType.ITEM, 8)
	set_column_custom_minimum_width(ColType.ITEM, 150)
	set_column_custom_minimum_width(ColType.TYPE, 90)
	_update_column_titles()
	item_selected.connect(_on_item_selected)
	mouse_exited.connect(func(): TooltipHandler.hide_tooltip())


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("mouse_left") or Input.is_action_pressed("mouse_right"):
			TooltipHandler.hide_tooltip()
		elif GlobalSettings.show_goblin_tooltips:
			var item: D2Item = get_item_at_mouse_pos(event.position)
			if item:
				TooltipHandler.show_tooltip_at_pos(item, get_tooltip_position())
			else:
				TooltipHandler.hide_tooltip()
	else:
		TooltipHandler.hide_tooltip()


func get_item_at_mouse_pos(pos: Vector2) -> D2Item:
	var row: TreeItem = get_item_at_position(pos)
	if not row:
		return null
	return row.get_metadata(0)


func get_tooltip_position() -> Vector2:
	var row: TreeItem = get_item_at_position(get_local_mouse_position())
	var row_rect: Rect2 = get_item_area_rect(row)
	return global_position + row_rect.position + Vector2(0, row_rect.size.y)


func _on_column_clicked(col_index: int, _mouse_button: int) -> void:
	var sort_key: ItemSorter.SortKey = COL_NAME_MAP[col_index]["sort_key"]
	if col_index == _sort_column:
		_sort_ascending = not _sort_ascending
	else:
		_sort_ascending = true
	_sort_column = col_index
	sort_requested.emit(sort_key, _sort_ascending)
	_update_column_titles()


func rebuild_display(items: Array[D2Item]) -> void:
	clear()
	_item_map.clear()
	create_item() # root
	for item: D2Item in items:
		_create_row(item)


func restore_last_selection(restore_selection: RestoreSelection, restore_fallback := RestoreFallback.NONE) -> void:
	match restore_selection:
		RestoreSelection.BY_INDEX:
			var child_count := get_root().get_child_count()
			if child_count >= _prev_selected_index + 1:
				_select_existing_row_by_index(_prev_selected_index)
				return
		RestoreSelection.BY_ITEM:
			if _item_map.has(_prev_selected_item):
				_item_map[_prev_selected_item].select(0)
				return
		RestoreSelection.NONE:
			return
	# Fallback
	match restore_fallback:
		RestoreFallback.FIRST_INDEX:
			_select_existing_row_by_index(0)
		RestoreFallback.LAST_INDEX:
			_select_existing_row_by_index(-1)


func _select_existing_row_by_index(index: int) -> void:
	if get_root().get_child_count() > 0:
		var row := get_root().get_child(index)
		if row:
			row.select(0)


func _create_row(item: D2Item) -> void:
	var row: TreeItem = create_item()
	_item_map[item] = row
	row.set_text(ColType.ITEM, item.item_name)
	row.set_text(ColType.TYPE, item.item_type)
	row.set_text(ColType.ETH, "e" if item.is_ethereal else "")
	row.set_text(ColType.CORRUPT, "*" if item.is_corrupted else "")
	row.set_text(ColType.SOCKETS, str(item.total_sockets) if item.is_socketed else "")
	row.set_metadata(0, item)

	row.set_custom_color(ColType.ITEM, D2Colors.get_item_color(item))
	row.set_custom_color(ColType.CORRUPT, D2Colors.COLOR_CORRUPTED)

	row.set_text_alignment(ColType.CORRUPT, HORIZONTAL_ALIGNMENT_CENTER)
	row.set_text_alignment(ColType.ETH, HORIZONTAL_ALIGNMENT_CENTER)
	row.set_text_alignment(ColType.SOCKETS, HORIZONTAL_ALIGNMENT_CENTER)

	_apply_sort_column_highlight(row)
	
	for socketed_item: D2Item in item.socketed_items:
		var child: TreeItem = row.create_child()
		child.set_text(ColType.ITEM, socketed_item.item_name)
		child.set_custom_color(ColType.ITEM, D2Colors.get_item_color(socketed_item))
		child.set_metadata(0, socketed_item)
	row.collapsed = true


func _update_column_titles() -> void:
	for col: int in ColType.values():
		var col_name: String = COL_NAME_MAP[col]["col_name"]
		if col == _sort_column:
			col_name += " ▲" if _sort_ascending else " ▼"
		set_column_title(col, col_name)


func _apply_sort_column_highlight(row: TreeItem) -> void:
	for col: int in ColType.values():
		if col == _sort_column:
			row.set_custom_bg_color(col, SORT_COLUMN_HIGHLIGHT)
		else:
			row.clear_custom_bg_color(col)


func _on_item_selected() -> void:
	var selected := get_selected()
	if selected.get_parent() != get_root(): # Socketed item
		selected = selected.get_parent()
	var item: D2Item = selected.get_metadata(0)
	_prev_selected_index = selected.get_index()
	_prev_selected_item = item
	
	item_clicked.emit(item)
