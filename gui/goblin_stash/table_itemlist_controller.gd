class_name TableItemListController
extends BasicItemListController

enum ColType {ITEM = 0, TYPE = 4, ETH = 1, CORRUPT = 2, SOCKETS = 3, BASE = 5, DMG = 6, DEF = 7, RES = 8, ILVL = 9, STASH = 10}
enum Highlight {NONE, HOVER, SELECTED}

const COL_NAME_MAP: Dictionary[ColType, Dictionary] = {
	ColType.ITEM: {"col_name": "Item", "sort_key": ItemSorter.SortKey.NAME},
	ColType.CORRUPT: {"col_name": "Corr", "sort_key": ItemSorter.SortKey.CORRUPT},
	ColType.TYPE: {"col_name": "Type", "sort_key": ItemSorter.SortKey.TYPE},
	ColType.ETH: {"col_name": "Eth", "sort_key": ItemSorter.SortKey.ETH},
	ColType.SOCKETS: {"col_name": "Soc", "sort_key": ItemSorter.SortKey.SOCKETS},
	ColType.BASE: {"col_name": "Base", "sort_key": ItemSorter.SortKey.BASE},
	ColType.DMG: {"col_name": "Dmg", "sort_key": ItemSorter.SortKey.DAM},
	ColType.DEF: {"col_name": "Def", "sort_key": ItemSorter.SortKey.DEF},
	ColType.RES: {"col_name": "Res", "sort_key": ItemSorter.SortKey.RES},
	ColType.ILVL: {"col_name": "iLvl", "sort_key": ItemSorter.SortKey.ILVL},
	ColType.STASH: {"col_name": "Stash", "sort_key": ItemSorter.SortKey.STASH},
}
const SORT_COLUMN_HIGHLIGHT: Color = Color(0.808, 0.847, 0.922, 0.027)

const SELECTED_ROW_COLOR := Color("71717198")
const HOVERED_ROW_COLOR := Color("ffffff12")
const NORMAL_FONT_COLOR := Color("#b3b3b3")
const SELECTED_FONT_COLOR := Color("dfdfdf")

var _sort_column: ColType = ColType.ITEM
var _sort_ascending: bool = true
var _item_map: Dictionary[D2Item, TreeItem]

var _tree: Tree
var _hovered_row: TreeItem

var _selection_anchor: TreeItem
var _selected_rows: Array[TreeItem]


func _init(tree: Tree) -> void:
	_tree = tree
	_tree.column_title_clicked.connect(_on_column_clicked)
	for col: int in COL_NAME_MAP:
		var col_name: String = COL_NAME_MAP[col].col_name
		_tree.set_column_title(col, col_name)
		_tree.set_column_expand(col, false)
		_tree.set_column_custom_minimum_width(col, _tree.get_column_width(col) + 20)
		_tree.set_column_title_alignment(col, HORIZONTAL_ALIGNMENT_CENTER)
	_tree.set_column_title_alignment(ColType.ITEM, HORIZONTAL_ALIGNMENT_CENTER)
	_tree.set_column_title_alignment(ColType.TYPE, HORIZONTAL_ALIGNMENT_LEFT)
	_tree.set_column_title_alignment(ColType.BASE, HORIZONTAL_ALIGNMENT_LEFT)
	_tree.set_column_title_alignment(ColType.STASH, HORIZONTAL_ALIGNMENT_LEFT)
	_tree.set_column_expand(ColType.ITEM, true)
	_tree.set_column_expand(ColType.TYPE, true)
	_tree.set_column_expand(ColType.BASE, true)
	_tree.set_column_expand(ColType.STASH, true)
	_tree.set_column_expand_ratio(ColType.ITEM, 8)
	#_tree.set_column_expand_ratio(ColType.STASH, 0)
	_tree.set_column_custom_minimum_width(ColType.ITEM, 330)
	_tree.set_column_custom_minimum_width(ColType.TYPE, 150)
	_tree.set_column_custom_minimum_width(ColType.BASE, 150)
	_tree.set_column_custom_minimum_width(ColType.STASH, 120)
	_update_column_titles()
	_tree.mouse_exited.connect(_on_mouse_exited)
	_tree.gui_input.connect(_gui_input)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var row: TreeItem = _tree.get_item_at_position(event.position)
	
			if row and row.get_parent() == _tree.get_root():
				_handle_row_selection(row, event)
				#_tree.accept_event()
				return
	
	elif event is InputEventKey:
		_tree.accept_event()
	
	elif event is InputEventMouseMotion:
		var new_row = _tree.get_item_at_position(event.position)
		if _hovered_row != new_row:
			if _hovered_row:
				if _selected_rows.has(_hovered_row):
					_highlight_row(_hovered_row, Highlight.SELECTED)
				else:
					_highlight_row(_hovered_row, Highlight.NONE)
		if new_row:
			if not _selected_rows.has(new_row):
				_highlight_row(new_row, Highlight.HOVER)
		_hovered_row = new_row
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
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
	var row: TreeItem = _tree.get_item_at_position(pos)
	if not row:
		return null
	return row.get_metadata(0)


func get_tooltip_position() -> Vector2:
	var row: TreeItem = _tree.get_item_at_position(_tree.get_local_mouse_position())
	var row_rect: Rect2 = _tree.get_item_area_rect(row)
	return _tree.global_position + row_rect.position + Vector2(0, row_rect.size.y)


func _on_column_clicked(col_index: int, _mouse_button: int) -> void:
	var sort_key: ItemSorter.SortKey = COL_NAME_MAP[col_index]["sort_key"]
	var sort_ascending := true
	if col_index == _sort_column:
		sort_ascending = not _sort_ascending
	sort_requested.emit(sort_key, sort_ascending)


func _on_mouse_exited() -> void:
	TooltipHandler.hide_tooltip()
	if _hovered_row:
		if _selected_rows.has(_hovered_row):
			return
		else:
			_highlight_row(_hovered_row, Highlight.NONE)


func accept_sort(sort_key: ItemSorter.SortKey, sort_ascending: bool) -> void:
	_sort_ascending = sort_ascending
	for col: ColType in COL_NAME_MAP:
		if COL_NAME_MAP[col].sort_key == sort_key:
			_sort_column = col
	_update_column_titles()


func rebuild_display(items: Array[D2Item]) -> void:
	_selected_rows.clear()
	_selection_anchor = null
	_hovered_row = null
	
	_tree.clear()
	_item_map.clear()
	_tree.create_item() # root
	for item: D2Item in items:
		_create_row(item)


func clear_selection() -> void:
	_clear_manual_selection()
	_prev_selected_items.clear()
	_selection_anchor = null
	items_selected.emit(_selected_items)


func select_all_items() -> void:
	_clear_manual_selection()
	var root := _tree.get_root()
	if not root:
		return
	var rows: Array[TreeItem] = root.get_children()
	for row: TreeItem in rows:
		_set_row_selected(row, true)
	if not rows.is_empty():
		_selection_anchor = rows[0]
	_emit_manual_selection()


func restore_last_selection(restore_selection: RestoreSelection, restore_fallback := RestoreFallback.NONE) -> void:
	match restore_selection:
		RestoreSelection.BY_INDEX:
			var child_count := _tree.get_root().get_child_count()
			if child_count >= _prev_selected_index + 1:
				_select_existing_row_by_index(_prev_selected_index)
				return
		RestoreSelection.BY_ITEM:
			_restore_previous_selection()
			return
		RestoreSelection.NONE:
			return
	# Fallback
	match restore_fallback:
		RestoreFallback.FIRST_INDEX:
			_select_existing_row_by_index(0)
		RestoreFallback.LAST_INDEX:
			_select_existing_row_by_index(-1)


func _restore_previous_selection() -> void:
	_clear_manual_selection()
	_selection_anchor = null

	var last_selected_row: TreeItem = null

	for item: D2Item in _prev_selected_items:
		if not _item_map.has(item):
			continue

		var row: TreeItem = _item_map[item]
		_set_row_selected(row, true)
		last_selected_row = row

	if last_selected_row:
		_selection_anchor = last_selected_row
		_prev_selected_index = last_selected_row.get_index()

	_emit_manual_selection()


func _select_existing_row_by_index(index: int) -> void:
	var root := _tree.get_root()
	if not root:
		return

	var rows: Array[TreeItem] = root.get_children()
	if rows.is_empty():
		return

	# Support negative indices, such as -1 for the last row.
	if index < 0:
		index += rows.size()

	if index < 0 or index >= rows.size():
		return

	var row: TreeItem = rows[index]
	_clear_manual_selection()
	_set_row_selected(row, true)

	_selection_anchor = row
	_save_previous_selection()
	_prev_selected_index = index

	_emit_manual_selection()


func _create_row(item: D2Item) -> void:
	var row: TreeItem = _tree.create_item()
	_item_map[item] = row
	row.set_text(ColType.ITEM, item.item_name)
	row.set_text(ColType.TYPE, item.item_type)
	row.set_text(ColType.BASE, item.base_name)
	row.set_text(ColType.ETH, "e" if item.is_ethereal else "")
	row.set_text(ColType.CORRUPT, "*" if item.is_corrupted else "")
	row.set_text(ColType.SOCKETS, str(item.total_sockets) if item.is_socketed else "")
	row.set_text(ColType.DMG, str(item.average_damage) if item.average_damage > 0 else "")
	row.set_text(ColType.DEF, str(item.defense) if item.defense > 0 else "")
	row.set_text(ColType.RES, str(item.total_res) if item.total_res > 0 else "")
	row.set_text(ColType.ILVL, str(item.item_level))
	var stash_id := ItemRegistry.item_view_register[item.item_id]
	row.set_text(ColType.STASH, StashRegistry.get_stash_name(ItemRegistry.item_view_register[item.item_id]))
	row.set_metadata(0, item)

	row.set_custom_color(ColType.ITEM, D2Colors.get_item_color(item))
	row.set_custom_color(ColType.CORRUPT, D2Colors.COLOR_CORRUPTED)

	row.set_text_alignment(ColType.CORRUPT, HORIZONTAL_ALIGNMENT_CENTER)
	row.set_text_alignment(ColType.ETH, HORIZONTAL_ALIGNMENT_CENTER)
	row.set_text_alignment(ColType.SOCKETS, HORIZONTAL_ALIGNMENT_CENTER)
	row.set_text_alignment(ColType.DMG, HORIZONTAL_ALIGNMENT_CENTER)
	row.set_text_alignment(ColType.DEF, HORIZONTAL_ALIGNMENT_CENTER)
	row.set_text_alignment(ColType.RES, HORIZONTAL_ALIGNMENT_CENTER)
	row.set_text_alignment(ColType.ILVL, HORIZONTAL_ALIGNMENT_CENTER)

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
		_tree.set_column_title(col, col_name)


func _apply_sort_column_highlight(row: TreeItem) -> void:
	for col: int in ColType.values():
		if col == _sort_column:
			row.set_custom_bg_color(col, SORT_COLUMN_HIGHLIGHT)
		else:
			row.clear_custom_bg_color(col)


func _highlight_row(row: TreeItem, highlight: Highlight) -> void:
	var row_color: Color
	match highlight:
		Highlight.NONE:
			row_color = Color.TRANSPARENT
		Highlight.HOVER:
			row_color = HOVERED_ROW_COLOR
		Highlight.SELECTED:
			row_color = SELECTED_ROW_COLOR
	var row_font_color: Color = SELECTED_FONT_COLOR if highlight else NORMAL_FONT_COLOR
	
	for col: int in ColType.values():
		if col == _sort_column:
			row.set_custom_bg_color(col, row_color.blend(SORT_COLUMN_HIGHLIGHT))
		else:
			row.set_custom_bg_color(col, row_color)
		if col != ColType.ITEM and col != ColType.CORRUPT:
			row.set_custom_color(col, row_font_color)



func _handle_row_selection(row: TreeItem, event: InputEventMouseButton) -> void:
	var ctrl_pressed := event.ctrl_pressed or event.meta_pressed
	var shift_pressed := event.shift_pressed

	if shift_pressed and _selection_anchor:
		_select_range(_selection_anchor, row)
	elif ctrl_pressed:
		_toggle_row_selection(row)
		_selection_anchor = row
	else:
		_clear_manual_selection()
		_set_row_selected(row, true)
		_selection_anchor = row

	_prev_selected_index = row.get_index()
	_save_previous_selection()
	_emit_manual_selection()


func _save_previous_selection() -> void:
	_prev_selected_items.clear()

	for selected_row: TreeItem in _selected_rows:
		var item: D2Item = selected_row.get_metadata(0)
		if item:
			_prev_selected_items.append(item)


func _toggle_row_selection(row: TreeItem) -> void:
	var is_selected: bool = _selected_rows.has(row)
	_set_row_selected(row, not is_selected)


func _set_row_selected(row: TreeItem, selected: bool) -> void:
	if selected:
		_highlight_row(row, Highlight.SELECTED)
		if not _selected_rows.has(row):
			_selected_rows.append(row)
	else:
		_highlight_row(row, Highlight.NONE)
		_selected_rows.erase(row)


func _clear_manual_selection() -> void:
	for row: TreeItem in _selected_rows.duplicate():
		_set_row_selected(row, false)
	_selected_rows.clear()


func _select_range(anchor: TreeItem, target: TreeItem) -> void:
	var root := _tree.get_root()
	var rows: Array[TreeItem] = root.get_children()

	var anchor_index := rows.find(anchor)
	var target_index := rows.find(target)

	if anchor_index == -1 or target_index == -1:
		return

	var start_index := mini(anchor_index, target_index)
	var end_index := maxi(anchor_index, target_index)

	_clear_manual_selection()

	for i: int in range(start_index, end_index + 1):
		_set_row_selected(rows[i], true)


func _emit_manual_selection() -> void:
	var items: Array[D2Item] = []

	for row: TreeItem in _selected_rows:
		var item: D2Item = row.get_metadata(0)
		if item:
			items.append(item)

	items_selected.emit(items)
