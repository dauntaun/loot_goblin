# StashRegistry
extends Node

signal registration_completed
signal stash_registered(stash_id: int)
signal stashes_unregistered
signal goblin_registered
signal pd2_shared_registered
signal characters_registered

enum StashType {UNKNOWN, GOBLIN, PD2_SHARED, PD2_MATERIALS, PD2_PERSONAL}

var _stash_register: Dictionary[int, Dictionary]

var _pd2_shared_stash_id := -1
var _pd2_shared_save: PD2SaveFile
var _goblin_main_stash_id := -1
var _goblin_save: GoblinSaveFile
var _character_register: Dictionary[int, Dictionary] # {"name": String, "char_stash": stash_id, "merc_stash": stash_id}
var _collection_register: Dictionary[int, Dictionary] # {"name": String, "stash": stash_id}
var _stash_name_map: Dictionary[int, String] ## stash_id -> stash name
var _character_stash_ids: Array[int]
var _collection_stash_ids: Array[int]


func complete_registration() -> void:
	registration_completed.emit()


func get_stash_name(stash_id: int) -> String:
	return _stash_name_map[stash_id]


func unregister_all_stashes() -> void:
	_pd2_shared_stash_id = -1
	_pd2_shared_save = null
	_goblin_main_stash_id = -1
	_goblin_save = null
	_stash_register.clear()
	_character_register.clear()
	_collection_register.clear()
	_stash_name_map.clear()
	_character_stash_ids.clear()
	_collection_stash_ids.clear()
	stashes_unregistered.emit()


func register_goblin_save(save_file: GoblinSaveFile) -> void:
	# Unregister
	for stash_id: int in get_goblin_collection_ids():
		_stash_register.erase(stash_id)
	_collection_register.clear()
	_collection_stash_ids.clear()
	_goblin_main_stash_id = -1
	_goblin_save = null
	# Register
	for collection: GoblinSaveFile.GoblinCollection in save_file.collections:
		if collection.name == "Main":
			_goblin_main_stash_id = collection.item_list.stash_id
		_collection_register[collection.collection_id] = {"name": collection.name, "stash_id": collection.item_list.stash_id} 
		_collection_stash_ids.append(collection.item_list.stash_id)
		_register_stash(
			collection.item_list.stash_id,
			StashType.GOBLIN,
			collection.item_list,
			collection.item_list.get_itemlist(),
			save_file)
		_stash_name_map[collection.item_list.stash_id] = "Goblin" + "/" + collection.name
	_goblin_save = save_file
	goblin_registered.emit()


func register_pd2_shared_save(save_file: PD2SaveFile) -> void:
	# Unregister
	_stash_register.erase(_pd2_shared_stash_id)
	_pd2_shared_stash_id = -1
	_pd2_shared_save = null
	# Register
	var stash_id := save_file.item_list.stash_id
	_register_stash(stash_id, StashType.PD2_SHARED, save_file.item_list, save_file.item_list.get_pd2pages(), save_file)
	_pd2_shared_stash_id = stash_id
	_pd2_shared_save = save_file
	_stash_name_map[stash_id] = "PD2 Shared"
	pd2_shared_registered.emit()



func register_character_save_files(save_files: Array[D2CharacterSaveFile]) -> void:
	# Unregister
	for stash_id: int in get_all_character_stash_ids():
		_stash_register.erase(stash_id)
	_character_register.clear()
	_character_stash_ids.clear()
	# Register
	for save: D2CharacterSaveFile in save_files:
		_register_character_save_file(save)
	characters_registered.emit()


func _register_character_save_file(save_file: D2CharacterSaveFile)  -> void:
	_character_register[save_file.character_id] = {
		"name": save_file.character_name,
		"char_stash": save_file.item_list.stash_id,
		"merc_stash": save_file.merc_item_list.stash_id if save_file.has_mercenary else -1}
	_register_stash(
		save_file.item_list.stash_id,
		StashType.PD2_PERSONAL,
		save_file.item_list,
		save_file.item_list.get_char_view(),
		save_file
	)
	_stash_name_map[save_file.item_list.stash_id] = save_file.character_name
	_character_stash_ids.append(save_file.item_list.stash_id)
	if save_file.has_mercenary:
		_register_stash(
			save_file.merc_item_list.stash_id,
			StashType.PD2_PERSONAL,
			save_file.merc_item_list,
			save_file.merc_item_list.get_char_view(),
			save_file
		)
		_stash_name_map[save_file.merc_item_list.stash_id] = save_file.character_name + "/" + "Merc"
		_character_stash_ids.append(save_file.merc_item_list.stash_id)


func _register_stash(
		stash_id: int,
		type: StashType,
		data: D2ItemList,
		view: BasicStashView,
		save_file: BasicSaveFile) -> void:
	
	_stash_register[stash_id] = {"type": type, "data": data, "view": view, "save": save_file}
	stash_registered.emit(stash_id)


func has_stash(stash_id: int) -> bool:
	return _stash_register.has(stash_id)

# ===== Getters =====

func get_pd2_shared_stash_id() -> int:
	return _pd2_shared_stash_id


func get_character_stash_id(character_id: int) -> int:
	return _character_register[character_id].char_stash


func get_all_character_stash_ids() -> Array[int]:
	return _character_stash_ids


func get_all_collection_stash_ids() -> Array[int]:
	return _collection_stash_ids


func get_mercenary_stash_id(character_id: int) -> int:
	return _character_register[character_id].merc_stash


func get_goblin_collection_names() -> Array[String]:
	var names: Array[String]
	for collection: Dictionary in _collection_register.values():
		names.append(collection.name)
	return names


func get_goblin_collection_ids() -> Array[int]:
	return _collection_register.keys()


func get_character_files() -> Array[D2CharacterSaveFile]:
	var files: Array[D2CharacterSaveFile]
	for character: Dictionary in _character_register.values():
		var file := get_stash_save(character.char_stash)
		files.append(file)
	return files


func get_character_names() -> Array[String]:
	var names: Array[String]
	for character: Dictionary in _character_register.values():
		names.append(character.name)
	return names


func get_character_ids() -> Array[int]:
	return _character_register.keys()


func get_goblin_main_stash_id() -> int:
	return _goblin_main_stash_id


func get_goblin_save_file() -> GoblinSaveFile:
	return _goblin_save


func get_pd2_shared_save_file() -> PD2SaveFile:
	return _pd2_shared_save


func get_goblin_stash_id(collection_id: int) -> int:
	return _collection_register[collection_id].stash_id


func get_stash_type(stash_id: int) -> StashType:
	if has_stash(stash_id):
		return _stash_register[stash_id].type
	else:
		return StashType.UNKNOWN


func get_stash_data(stash_id: int) -> D2ItemList:
	return _stash_register[stash_id].data


func get_stash_view(stash_id: int) -> BasicStashView:
	return _stash_register[stash_id].view


func get_stash_save(stash_id: int) -> BasicSaveFile:
	return _stash_register[stash_id].save
