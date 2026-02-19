# StashRegistry
extends Node

signal stash_registered(stash: StashType)

enum StashType {UNKNOWN, GOBLIN, PD2_SHARED, PD2_MATERIALS, PD2_PERSONAL}

const PD2_STASH_TYPES := [StashType.PD2_SHARED, StashType.PD2_MATERIALS, StashType.PD2_PERSONAL]

var _stash_entries: Dictionary[StashType, StashEntry]
var _stash_data: Dictionary[StashType, D2ItemList]
var _stash_views: Dictionary[StashType, BasicStashView]
var _stash_files: Dictionary[StashType, BasicSaveFile]


func register_stash(type: StashType, data: D2ItemList, view: BasicStashView, save_file: BasicSaveFile) -> void:
	_stash_entries[type] = StashEntry.new(data, view)
	_stash_data[type] = data
	_stash_views[type] = view
	_stash_files[type] = save_file
	stash_registered.emit(type)


func unregister_stash(type: StashType) -> void:
	_stash_entries.erase(type)
	_stash_data.erase(type)
	_stash_views.erase(type)


func get_stash_entry(type: StashType) -> StashEntry:
	if not _stash_entries.has(type):
		return null
	return _stash_entries[type]


func get_stash_view(type: StashType) -> BasicStashView:
	return _stash_views[type]


func get_save_file(type: StashType) -> BasicSaveFile:
	return _stash_files.get(type)


func has_stash(type: StashType) -> bool:
	return _stash_entries.has(type)


func get_stash_type_from_data(data: D2ItemList) -> StashRegistry.StashType:
	var key = _stash_data.find_key(data)
	if key:
		return key
	else:
		return StashType.UNKNOWN


class StashEntry:
	var data: D2ItemList
	var view: BasicStashView
	
	
	func _init(stash_data: D2ItemList, stash_view: BasicStashView) -> void:
		data = stash_data
		view = stash_view
