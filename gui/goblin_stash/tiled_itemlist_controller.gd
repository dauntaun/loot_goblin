class_name TiledItemListController
extends BasicItemListController

const ITEM_TOOLTIP_SCENE := preload("uid://dfqosv12wxnro")
const MASONRY_ITEM_TOOLTIP_STYLEBOX: StyleBox = preload("uid://c163oia6j5fbw")

var _container: MasonryContainer


func _init(container: MasonryContainer) -> void:
	_container = container


func rebuild_display(items: Array[D2Item]) -> void:
	_container.get_children().map(func(x: Node) -> void: x.queue_free())
	for item: D2Item in items:
		_create_item_panel(item)


func restore_last_selection(restore_selection: RestoreSelection, restore_fallback := RestoreFallback.NONE) -> void:
	pass


func _create_item_panel(item: D2Item) -> void:
	var tooltip: ItemTooltip = ITEM_TOOLTIP_SCENE.instantiate()
	_container.add_child(tooltip)
	tooltip.add_theme_stylebox_override("panel", MASONRY_ITEM_TOOLTIP_STYLEBOX)
	tooltip.set_compact_tooltip(true)
	tooltip.update_tooltip(item)
