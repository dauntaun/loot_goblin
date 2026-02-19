class_name PagedStashView
extends BasicStashView

const MAX_STASH_PAGES: int = 9

var _grids: Array[InventoryGrid]
var _item_page_map: Dictionary[D2Item, int]


func _init(items: Array[D2Item]) -> void:
	for i: int in MAX_STASH_PAGES:
		var grid := InventoryGrid.new()
		_grids.append(InventoryGrid.new())
	_init_items(items)
	super(items)


func can_add_items(items: Array[D2Item], page_index: int) -> bool:
	return _grids[page_index].can_fit_items(items)


func find_space(item: D2Item, page_index: int) -> Vector2i:
	return _grids[page_index].find_space(item)


func get_placement(item: D2Item, page_index: int) -> ItemPlacement:
	var placement := ItemPlacement.new()
	placement.coord = find_space(item, page_index)
	placement.equipped_id = page_index + 1 as D2Item.EquipLocation
	placement.store_id = D2Item.PD2_STORE_LOCATION
	return placement


func add_item(item: D2Item) -> void:
	var page_index := item.equipped_id - 1
	var coord := item.get_coord()
	_grids[page_index].add_item_at_coord(item, coord)
	_item_page_map[item] = page_index
	super(item)


func remove_item(item: D2Item) -> void:
	var page_index := _item_page_map[item]
	_grids[page_index].remove_item(item)
	_item_page_map.erase(item)
	super(item)


func get_items_in_page(page_index: int) -> Array[D2Item]:
	return _grids[page_index].get_items()


func is_page_empty(page_index: int) -> bool:
	return get_items_in_page(page_index).is_empty()


func _init_items(items: Array[D2Item]) -> void:
	for item: D2Item in items:
		_grids[item.equipped_id - 1].add_item_at_coord(item, item.get_coord())
		_item_page_map[item] = item.equipped_id - 1
