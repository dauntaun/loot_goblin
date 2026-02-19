class_name InventoryGrid

const GRID_WIDTH: int = 10
const GRID_HEIGHT: int = 15
const GRIDS_AMOUNT: int = GRID_WIDTH * GRID_HEIGHT

var _grid: Array[Array]
var _items: Array[D2Item]


func _init() -> void:
	for y: int in GRID_HEIGHT:
		_grid.append([])
		for x: int in GRID_WIDTH:
			_grid[y].append(null)


func get_items() -> Array[D2Item]:
	return _items


func remove_item(item: D2Item) -> void:
	_items.erase(item)
	for y: int in GRID_HEIGHT:
		for x: int in GRID_WIDTH:
			if _grid[y][x] == item:
				_grid[y][x] = null


func add_item_at_coord(item: D2Item, coord: Vector2i) -> void:
	_items.append(item)
	for y: int in item.inv_height:
		for x: int in item.inv_width:
			_grid[coord.y + y][coord.x + x] = item


func find_space(item: D2Item) -> Vector2i:
	for y: int in (GRID_HEIGHT - item.inv_height + 1):
		for x: int in (GRID_WIDTH - item.inv_width + 1):
			var pos := Vector2i(x, y)
			if can_place(item, pos):
				return pos
	return Vector2i(-1, -1) # no space


func can_fit_items(items: Array[D2Item]) -> bool:
	if items.size() > GRIDS_AMOUNT:
		return false
	# Copy current grid
	var temp_grid: Array = []
	for y: int in GRID_HEIGHT:
		temp_grid.append(_grid[y].duplicate())

	for item: D2Item in items:
		var placed := false

		for y: int in (GRID_HEIGHT - item.inv_height + 1):
			for x: int in (GRID_WIDTH - item.inv_width + 1):
				var pos := Vector2i(x, y)

				# Bounds check
				if pos.x < 0 or pos.y < 0:
					continue
				if pos.x + item.inv_width > GRID_WIDTH:
					continue
				if pos.y + item.inv_height > GRID_HEIGHT:
					continue

				# Collision check
				var blocked := false
				for iy: int in item.inv_height:
					for ix: int in item.inv_width:
						if temp_grid[pos.y + iy][pos.x + ix] != null:
							blocked = true
							break
					if blocked:
						break

				if blocked:
					continue

				# Place item into temp grid
				for iy: int in item.inv_height:
					for ix: int in item.inv_width:
						temp_grid[pos.y + iy][pos.x + ix] = item

				placed = true
				break
			if placed:
				break

		if not placed:
			return false

	return true



func can_place(item: D2Item, pos: Vector2i) -> bool:
	if pos.x < 0 or pos.y < 0:
		return false
	if pos.x + item.inv_width > GRID_WIDTH:
		return false
	if pos.y + item.inv_height > GRID_HEIGHT:
		return false

	for y: int in item.inv_height:
		for x: int in item.inv_width:
			if _grid[pos.y + y][pos.x + x] != null:
				return false
	return true
