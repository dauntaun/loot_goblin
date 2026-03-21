# StashRegistry
extends Node

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


func unregister_all_stashes() -> void:
	_pd2_shared_stash_id = -1
	_pd2_shared_save = null
	_goblin_main_stash_id = -1
	_goblin_save = null
	_stash_register.clear()
	_character_register.clear()
	_collection_register.clear()
	stashes_unregistered.emit()


func register_goblin(stash_entries: Array[Dictionary], save_file: BasicSaveFile) -> void:
	# Unregister
	for stash_id: int in get_goblin_collection_ids():
		_stash_register.erase(stash_id)
	_collection_register.clear()
	_goblin_main_stash_id = -1
	_goblin_save = null
	# Register
	for collection_entry: Dictionary in stash_entries:
		if collection_entry.name == "Main":
			_goblin_main_stash_id = collection_entry.stash_id
		_collection_register[collection_entry.collection_id] = {"name": collection_entry.name, "stash_id": collection_entry.stash_id} 
		_register_stash(
			collection_entry.stash_id,
			StashType.GOBLIN,
			collection_entry.data,
			collection_entry.view,
			save_file)
	_goblin_save = save_file
	goblin_registered.emit()


func register_pd2_shared(stash_id: int, data: D2ItemList, view: BasicStashView, save_file: BasicSaveFile) -> void:
	# Unregister
	_stash_register.erase(_pd2_shared_stash_id)
	_pd2_shared_stash_id = -1
	_pd2_shared_save = null
	# Register
	_register_stash(stash_id, StashType.PD2_SHARED, data, view, save_file)
	_pd2_shared_stash_id = stash_id
	_pd2_shared_save = save_file
	pd2_shared_registered.emit()



func register_characters(characters: Array[Dictionary]) -> void:
	# Unregister
	for stash_id: int in get_all_character_stash_ids():
		_stash_register.erase(stash_id)
	_character_register.clear()
	# Register
	for character: Dictionary in characters:
		_register_character(character.id, character.name, character.save, character.stash, character.merc_stash)
	characters_registered.emit()


func _register_character(character_id: int, char_name: String, save_file: BasicSaveFile, char_stash: Dictionary, merc_stash: Dictionary = {})  -> void:
	_character_register[character_id] = {"name": char_name, "char_stash": char_stash.stash_id, "merc_stash": merc_stash.get("stash_id", -1)}
	_register_stash(
		char_stash.stash_id,
		StashType.PD2_PERSONAL,
		char_stash.data,
		char_stash.view,
		save_file
	)
	if not merc_stash.is_empty():
		_register_stash(
			merc_stash.stash_id,
			StashType.PD2_PERSONAL,
			merc_stash.data,
			merc_stash.view,
			save_file
		)


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
	var stash_ids: Array[int]
	for character_id: int in _character_register:
		var char_stash_id := get_character_stash_id(character_id)
		var merc_stash_id := get_mercenary_stash_id(character_id)
		stash_ids.append(char_stash_id)
		if merc_stash_id != -1:
			stash_ids.append(merc_stash_id)
	return stash_ids


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
