class_name BasicStashView

signal item_added(item: D2Item)
signal item_removed(item: D2Item)
signal items_imported
signal list_cleared

var _items: Array[D2Item]


func _init(items: Array[D2Item]) -> void:
	_items = items
	for item: D2Item in items:
		ItemRegistry.item_view_register[item.item_id] = self


@warning_ignore("unused_parameter")
func get_placement(item: D2Item, page_index: int) -> ItemPlacement:
	return null


@warning_ignore("unused_parameter")
func can_add_items(items: Array[D2Item], page_index: int) -> bool:
	return true


func add_item(item: D2Item) -> void:
	_items.append(item)
	ItemRegistry.item_view_register[item.item_id] = self
	item_added.emit(item)


func remove_item(item: D2Item) -> void:
	_items.erase(item)
	item_removed.emit(item)


func get_items() -> Array[D2Item]:
	return _items


func import_items(items: Array[D2Item]) -> void:
	_items.append_array(items)
	for item: D2Item in items:
		ItemRegistry.item_view_register[item.item_id] = self
	items_imported.emit()


func clear_list() -> void:
	_items.clear()
	list_cleared.emit()


func get_equipped_items() -> Array[D2Item]:
	var result: Array[D2Item]
	for item: D2Item in get_items():
		if item.location_id == D2Item.ItemLocation.EQUIPPED:
			result.append(item)
	return result


func get_inventory_items() -> Array[D2Item]:
	var result: Array[D2Item]
	for item: D2Item in get_items():
		if item.store_id == D2Item.StoreLocation.INVENTORY:
			result.append(item)
	return result


func get_stashed_items() -> Array[D2Item]:
	var result: Array[D2Item]
	for item: D2Item in get_items():
		if item.store_id in [D2Item.StoreLocation.STASH, D2Item.StoreLocation.PD2_STASH]:
			result.append(item)
	return result


func get_cube_items() -> Array[D2Item]:
	var result: Array[D2Item]
	for item: D2Item in get_items():
		if item.store_id == D2Item.StoreLocation.CUBE:
			result.append(item)
	return result
