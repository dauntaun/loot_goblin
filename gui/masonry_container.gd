@tool
class_name MasonryContainer
extends Container

enum ColumnMode {SHORTEST, ALTERNATING}

@export var column_mode: ColumnMode
@export var minimum_column_width := 100
@export var v_margins := 4
@export var h_margins := 4

var _columns: int
var _column_width: int
var _children: Array[Node]


func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		_position_children()


func _position_children() -> void:
	_children = get_children()
	if not _children:
		return
	_recalculate_column_count()
	if _columns == 0:
		return
	_recalculate_column_width()
	
	# Track current height of each column
	var column_heights: Array[int] = []
	column_heights.resize(_columns)
	for i: int in _columns:
		column_heights[i] = 0

	var current_column: int = 0

	for i: int in _children.size():
		var node := _children[i]
		node.position.x = current_column * _column_width + (h_margins * current_column)
		node.size.x = _column_width
		node.size.y = node.get_combined_minimum_size().y
		node.position.y = column_heights[current_column]
		column_heights[current_column] += node.size.y + v_margins
		if column_mode == ColumnMode.SHORTEST:
			current_column = column_heights.find(column_heights.min())
		else:
			current_column += 1
			current_column %= _columns
	
	custom_minimum_size.y = column_heights.max()


func _recalculate_column_width() -> void:
	_column_width = (int(size.x) - (h_margins * (_columns - 1))) / _columns


func _recalculate_column_count():
	_columns = 0
	var cumulative_width: int = 0
	for node: Control in _children:
		cumulative_width += minimum_column_width + h_margins / 2
		if cumulative_width <= size.x:
			_columns += 1
		else:
			break


func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return []


func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return []
