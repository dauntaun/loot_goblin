# TooltipHandler
extends CanvasLayer

const TOOLTIP_SCENE := preload("uid://dfqosv12wxnro")


var _tooltip: ItemTooltip
var _current_item: D2Item
var _screen: Viewport


func _ready() -> void:
	_screen = get_viewport()
	_tooltip = TOOLTIP_SCENE.instantiate()
	_tooltip.hide()
	add_child(_tooltip)


func show_tooltip_above_target(item: D2Item, target: Node) -> void:
	if item ==_current_item and _tooltip.visible:
		return
	_current_item = item
	_tooltip.label.clear()
	_tooltip.size = Vector2.ZERO
	_tooltip.show()
	_tooltip.update_tooltip(item)
	_tooltip.global_position = target.global_position
	# Center vertically
	_tooltip.global_position.y -= _tooltip.size.y
	# Center horizontally
	_tooltip.global_position.x -= _tooltip.size.x / 2
	_tooltip.global_position.x += target.size.x / 2
	# Clamp to screen limits
	var screen_limits := _screen.get_visible_rect().size
	_tooltip.global_position.x = clamp(_tooltip.global_position.x, 0, screen_limits.x - _tooltip.size.x)
	_tooltip.global_position.y = clamp(_tooltip.global_position.y, 0, screen_limits.y - _tooltip.size.y)


func show_tooltip_at_pos(item: D2Item, pos: Vector2) -> void:
	_tooltip.label.clear()
	_tooltip.size = Vector2.ZERO
	_tooltip.show()
	_tooltip.update_tooltip(item)
	_tooltip.global_position = pos
	# Clamp to screen limits
	var screen_limits := _screen.get_visible_rect().size
	_tooltip.global_position.x = clamp(_tooltip.global_position.x, 0, screen_limits.x - _tooltip.size.x)
	_tooltip.global_position.y = clamp(_tooltip.global_position.y, 0, screen_limits.y - _tooltip.size.y)


func hide_tooltip() -> void:
	_tooltip.hide()
