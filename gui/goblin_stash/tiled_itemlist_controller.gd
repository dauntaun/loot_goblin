class_name TiledItemListController
extends BasicItemListController

const ITEM_TOOLTIP_SCENE := preload("uid://dfqosv12wxnro")
const MASONRY_ITEM_TOOLTIP_STYLEBOX: StyleBox = preload("uid://c163oia6j5fbw")

var _container: Container
var _item_map: Dictionary[D2Item, Button]


func _init(container: Container) -> void:
	_container = container


func rebuild_display(items: Array[D2Item]) -> void:
	_item_map.clear()
	_container.get_children().map(func(x: Node) -> void: x.queue_free())
	for item: D2Item in items:
		_create_item_panel(item)


func select_all_items() -> void:
	_selected_items.clear()

	for item: D2Item in _item_map:
		_selected_items.append(item)
		_item_map[item].set_pressed_no_signal(true)

	_save_previous_selection()
	items_selected.emit(_selected_items.duplicate())


func clear_selection() -> void:
	for button: Button in _item_map.values():
		button.set_pressed_no_signal(false)

	_selected_items.clear()
	_prev_selected_items.clear()
	_save_previous_selection()
	items_selected.emit(_selected_items)


func restore_last_selection(restore_selection: RestoreSelection, restore_fallback := RestoreFallback.NONE) -> void:
	match restore_selection:
		RestoreSelection.BY_INDEX:
			var item: D2Item = _item_map.keys().get(_prev_selected_index) as D2Item
			if item:
				_restore_items([item])
				return

		RestoreSelection.BY_ITEM:
			if not _prev_selected_items.is_empty():
				_restore_items(_prev_selected_items)
				if not _selected_items.is_empty():
					return

		RestoreSelection.NONE:
			return

	# Fallback
	var items: Array = _item_map.keys()
	match restore_fallback:
		RestoreFallback.FIRST_INDEX:
			var item: D2Item = items.get(0) as D2Item
			if item:
				_restore_items([item])

		RestoreFallback.LAST_INDEX:
			var item: D2Item = items.back() as D2Item if not items.is_empty() else null
			if item:
				_restore_items([item])


func _restore_items(items: Array[D2Item]) -> void:
	_selected_items.clear()

	# Clear all button states first.
	for button: Button in _item_map.values():
		button.set_pressed_no_signal(false)

	# Restore every item that still exists.
	for item: D2Item in items:
		if not _item_map.has(item):
			continue

		if item in _selected_items:
			continue

		_selected_items.append(item)
		_item_map[item].set_pressed_no_signal(true)

	if not _selected_items.is_empty():
		_prev_selected_index = _item_map.keys().find(_selected_items.back())

	_save_previous_selection()
	items_selected.emit(_selected_items.duplicate())


func _save_previous_selection() -> void:
	_prev_selected_items = _selected_items.duplicate()


func _create_item_panel(item: D2Item) -> void:
	var tooltip: ItemTooltip = ITEM_TOOLTIP_SCENE.instantiate()
	var button := Button.new()
	var vbox := VBoxContainer.new()
	var texture_rect := TextureRect.new()
	texture_rect.texture = TxtDB.get_item_invfile(item)
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_item_map[item] = button
	button.toggle_mode = true
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	tooltip.add_child(button)
	tooltip.move_child(button, 0)
	button.toggled.connect(_on_item_tooltip_pressed.bind(item, button))
	_container.add_child(tooltip)
	vbox.add_child(texture_rect)
	tooltip.add_child(vbox)
	tooltip.label.reparent(vbox)
	tooltip.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	tooltip.set_compact_tooltip(true)
	tooltip.update_tooltip(item)
	tooltip.custom_minimum_size.y = 100
	tooltip.mouse_filter = Control.MOUSE_FILTER_PASS
	button.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED


func _on_item_tooltip_pressed(_toggled: bool, item: D2Item, button: Button) -> void:
	if Input.is_key_pressed(KEY_CTRL):
		if item in _selected_items:
			_selected_items.erase(item)
			button.set_pressed_no_signal(false)
		else:
			_selected_items.append(item)
	else:
		_selected_items.clear()
		_selected_items.append(item)

		for selected_item: D2Item in _item_map:
			_item_map[selected_item].set_pressed_no_signal(selected_item == item)

	_prev_selected_index = _item_map.keys().find(item)

	_save_previous_selection()
	items_selected.emit(_selected_items.duplicate())
