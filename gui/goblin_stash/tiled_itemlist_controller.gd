class_name TiledItemListController
extends BasicItemListController

const ITEM_TOOLTIP_SCENE := preload("uid://dfqosv12wxnro")
const MASONRY_ITEM_TOOLTIP_STYLEBOX: StyleBox = preload("uid://c163oia6j5fbw")

var _container: Container
var _item_map: Dictionary[D2Item, Button]
var _button_group := ButtonGroup.new()


func _init(container: Container) -> void:
	_container = container
	_button_group.allow_unpress = false


func rebuild_display(items: Array[D2Item]) -> void:
	_item_map.clear()
	_container.get_children().map(func(x: Node) -> void: x.queue_free())
	for item: D2Item in items:
		_create_item_panel(item)


func restore_last_selection(restore_selection: RestoreSelection, restore_fallback := RestoreFallback.NONE) -> void:
	match restore_selection:
		RestoreSelection.BY_INDEX:
			var button := _item_map.values().get(_prev_selected_index) as Button
			if button:
				button.button_pressed = true
		RestoreSelection.BY_ITEM:
			var button := _item_map.get(_prev_selected_item) as Button
			if button:
				button.button_pressed = true
		RestoreSelection.NONE:
			return
	# Fallback
	match restore_fallback:
		RestoreFallback.FIRST_INDEX:
			var button := _item_map.values().get(0) as Button
			if button:
				button.button_pressed = true
		RestoreFallback.LAST_INDEX:
			var button := _item_map.values().get(-1) as Button
			if button:
				button.button_pressed = true


func _create_item_panel(item: D2Item) -> void:
	var tooltip: ItemTooltip = ITEM_TOOLTIP_SCENE.instantiate()
	var button := Button.new()
	_item_map[item] = button
	button.toggle_mode = true
	button.button_group = _button_group
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	tooltip.add_child(button)
	tooltip.move_child(button, 0)
	button.toggled.connect(_on_item_tooltip_pressed.bind(item))
	_container.add_child(tooltip)
	tooltip.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	tooltip.set_compact_tooltip(true)
	tooltip.update_tooltip(item)
	tooltip.custom_minimum_size.y = 150
	tooltip.mouse_filter = Control.MOUSE_FILTER_PASS
	button.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED


func _on_item_tooltip_pressed(_toggled: bool, item: D2Item) -> void:
	_prev_selected_item = item
	_prev_selected_index = _item_map.keys().find(item)
	item_selected.emit(item)
