class_name StashSelector
extends HBoxContainer

signal stashes_changed(stashes: Array[BasicStashView])

var _pd2_option_map: Dictionary[int, Array] ## option_id -> Array[stash_id]
var _collection_option_map: Dictionary[int, int] ## option_id -> stash_id

@onready var _stash_select_option: OptionButton = %StashSelectOption
@onready var _stash_select_tabs: TabContainer = %StashSelectTabs
@onready var _collection_select_option: OptionButton = %GoblinSelectOption
@onready var _pd2_select_option: OptionButton = %PD2SelectOption


func _ready() -> void:
	_stash_select_option.item_selected.connect(_on_stash_selected)
	_collection_select_option.item_selected.connect(_on_collection_option_selected)
	_pd2_select_option.item_selected.connect(_on_pd2_option_selected)


func is_virtual_stash_selected() -> bool:
	if _stash_select_option.selected == 1: # Goblin
		if not _collection_select_option.selected == 0: # All
			return false
		else:
			return true
	elif _stash_select_option.selected == 2: # PD2
		if not _pd2_select_option.selected == 0: # All
			return false
		else:
			return true
	else: # All
		return true


func select_default() -> void:
	update_stash_select_options()
	_stash_select_option.select(1)
	_collection_select_option.select(1)
	_on_stash_selected(1)


func update_stash_select_options() -> void:
	_pd2_select_option.clear()
	_pd2_option_map.clear()
	
	var pd2_shared_stash_id := StashRegistry.get_pd2_shared_stash_id()
	var character_names := StashRegistry.get_character_names()
	var character_ids := StashRegistry.get_character_ids()
	
	_pd2_select_option.add_item("All")
	if pd2_shared_stash_id != -1:
		_pd2_select_option.add_item("PD2 Shared")
		_pd2_option_map[_pd2_select_option.item_count - 1] = [pd2_shared_stash_id]
	for i: int in character_names.size():
		_pd2_select_option.add_item(character_names[i])
		var stash_ids: Array[int]
		stash_ids.append(StashRegistry.get_character_stash_id(character_ids[i]))
		var merc_stash_id := StashRegistry.get_mercenary_stash_id(character_ids[i])
		if merc_stash_id != -1:
			stash_ids.append(merc_stash_id)
		_pd2_option_map[_pd2_select_option.item_count - 1] = stash_ids


	_collection_select_option.clear()
	_collection_option_map.clear()
	
	var collection_names := StashRegistry.get_goblin_collection_names()
	var collection_ids := StashRegistry.get_all_collection_stash_ids()
	_collection_select_option.add_item("All")
	for i: int in collection_ids.size():
		_collection_select_option.add_item(collection_names[i])
		_collection_option_map[_collection_select_option.item_count - 1] = collection_ids[i]


func _on_stash_selected(option_index: int) -> void:
	match option_index:
		0: # All
			var init_stashes: Array[BasicStashView]
			var goblin_main_stash_id := StashRegistry.get_goblin_main_stash_id()
			var pd2_shared_stash_id := StashRegistry.get_pd2_shared_stash_id()
			if goblin_main_stash_id != -1:
				init_stashes.append(StashRegistry.get_stash_view(goblin_main_stash_id))
			if pd2_shared_stash_id != -1:
				init_stashes.append(StashRegistry.get_stash_view(pd2_shared_stash_id))
			for stash_id: int in StashRegistry.get_all_character_stash_ids():
				init_stashes.append(StashRegistry.get_stash_view(stash_id))
			_stash_select_tabs.hide()
			stashes_changed.emit(init_stashes)
		1: # Goblin
			var init_stashes: Array[BasicStashView]
			if _collection_select_option.selected == 0:
				for stash_id: int in _collection_option_map.values():
					init_stashes.append(StashRegistry.get_stash_view(stash_id))
			else:
				var stash_id := _collection_option_map[_collection_select_option.selected]
				init_stashes.append(StashRegistry.get_stash_view(stash_id))
			_stash_select_tabs.current_tab = 0
			_stash_select_tabs.show()
			stashes_changed.emit(init_stashes)
		2: # PD2
			var init_stashes: Array[BasicStashView]
			if _pd2_select_option.selected == 0:
				for stash_ids: Array in _pd2_option_map.values():
					for stash_id: int in stash_ids:
						init_stashes.append(StashRegistry.get_stash_view(stash_id))
			else:
				var stash_ids := _pd2_option_map[_pd2_select_option.selected]
				for stash_id: int in stash_ids:
					init_stashes.append(StashRegistry.get_stash_view(stash_id))
			_stash_select_tabs.current_tab = 1
			_stash_select_tabs.show()
			stashes_changed.emit(init_stashes)


func _on_pd2_option_selected(option_index: int) -> void:
	var init_stashes: Array[BasicStashView]
	if option_index == 0:
		for stash_ids: Array in _pd2_option_map.values():
			for stash_id: int in stash_ids:
				init_stashes.append(StashRegistry.get_stash_view(stash_id))
	else:
		var stash_ids := _pd2_option_map[_pd2_select_option.selected]
		for stash_id: int in stash_ids:
			init_stashes.append(StashRegistry.get_stash_view(stash_id))
	stashes_changed.emit(init_stashes)


func _on_collection_option_selected(option_index: int) -> void:
	var init_stashes: Array[BasicStashView]
	if option_index == 0:
		for stash_id: int in _collection_option_map.values():
			init_stashes.append(StashRegistry.get_stash_view(stash_id))
	else:
		var stash_id := _collection_option_map[_collection_select_option.selected]
		init_stashes.append(StashRegistry.get_stash_view(stash_id))
	stashes_changed.emit(init_stashes)
