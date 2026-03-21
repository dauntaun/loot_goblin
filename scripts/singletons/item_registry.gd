# ItemRegistry
extends Node

var item_register: Dictionary[int, D2Item] ## item_id -> D2Item
var item_data_register: Dictionary[int, int] ## item_id -> stash_id (d2itemlist)
var item_view_register: Dictionary[int, int] ## item_id -> stash_id (view)


func get_item_data_stash_id(item_id: int) -> int:
	return item_data_register[item_id]


func get_item_view_stash_id(item_id: int) -> int:
	return item_view_register[item_id]


func unregister_all_items() -> void:
	item_register.clear()
	item_data_register.clear()
	item_view_register.clear()


func unregister_items_from_stash(stash_id: int) -> void:
	var to_remove: Array[int]

	for item_id: int in item_data_register:
		if item_data_register[item_id] == stash_id:
			to_remove.append(item_id)

	for item_id: int in item_view_register:
		if item_view_register[item_id] == stash_id:
			if not to_remove.has(item_id):
				to_remove.append(item_id)

	for item_id: int in to_remove:
		item_register.erase(item_id)
		item_data_register.erase(item_id)
		item_view_register.erase(item_id)
