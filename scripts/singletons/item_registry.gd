# ItemRegistry
extends Node

var item_data_register: Dictionary[int, D2ItemList]
var item_view_register: Dictionary[int, BasicStashView]


func get_item_data(item_id: int) -> D2ItemList:
	return item_data_register[item_id]


func get_item_view(item_id: int) -> BasicStashView:
	return item_view_register[item_id]


func get_item_stash(item_id: int) -> StashRegistry.StashType:
	var source := get_item_data(item_id)
	return StashRegistry.get_stash_type_from_data(source)
