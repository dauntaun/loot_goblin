@tool
class_name StashGridView
extends MasonryContainer

const ITEM_TOOLTIP_SCENE := preload("uid://dfqosv12wxnro")


func _ready() -> void:
	pass


func rebuild_display(items: Array[D2Item]) -> void:
	get_children().map(func(x: Node) -> void: x.queue_free())
	for item: D2Item in items:
		_create_item_panel(item)


func _create_item_panel(item: D2Item) -> void:
	var tooltip: ItemTooltip = ITEM_TOOLTIP_SCENE.instantiate()
	add_child(tooltip)
	#tooltip.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	tooltip.remove_theme_stylebox_override("panel")
	tooltip.set_compact_tooltip(true)
	tooltip.update_tooltip(item)
