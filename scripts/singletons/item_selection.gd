# ItemSelection
extends Node

# Source changed
signal selection_changed
# Destination changed
signal destination_changed(new_stash_type: StashRegistry.StashType)
signal active_page_changed(new_page: int)
signal active_collection_changed(new_collection_id: int)
signal active_character_changed(new_character_id: int)
# Transfer occurred
signal items_transferred(to_stash_id: int)
signal stash_cleared
signal plugy_imported

enum SelectionTransferOutcome {ALLOWED, QUEUE_BLOCKED, NO_ITEMS, NO_SPACE, SAME_DESTINATION}

# Source state
var _selected_items: Array[D2Item]
# Destination state
var _destination_stash_type: StashRegistry.StashType
var _destination_page_index := 8
var _destination_collection_id := -1
var _destination_character_id := -1


func set_selection(items: Array[D2Item]) -> void:
	if items.is_empty():
		clear_selection()
		return
	if _selected_items != items:
		_selected_items = items
		selection_changed.emit()


func clear_selection() -> void:
	if _selected_items:
		_selected_items = []
		selection_changed.emit()


func clear_destination() -> void:
	_destination_collection_id = -1
	_destination_character_id = -1
	_destination_stash_type = StashRegistry.StashType.UNKNOWN


func get_last_selected_item() -> D2Item:
	if _selected_items.is_empty():
		return null
	else:
		return _selected_items[0]


func get_selected_items() -> Array[D2Item]:
	return _selected_items


func set_destination_page_index(page_index: int) -> void:
	page_index = clamp(page_index, 0, 8)
	if _destination_page_index != page_index:
		_destination_page_index = page_index
		active_page_changed.emit(page_index)


func set_destination_character(character_id: int) -> void:
	if _destination_character_id != character_id:
		_destination_character_id = character_id
		active_character_changed.emit(character_id)


func set_destination_collection(collection_id: int) -> void:
	if _destination_collection_id != collection_id:
		_destination_collection_id = collection_id
		active_collection_changed.emit(collection_id)


func get_destination_stash_id() -> int:
	match _destination_stash_type:
		StashRegistry.StashType.GOBLIN:
			return StashRegistry.get_goblin_stash_id(_destination_collection_id)
		StashRegistry.StashType.PD2_SHARED:
			return StashRegistry.get_pd2_shared_stash_id()
		StashRegistry.StashType.PD2_PERSONAL:
			return StashRegistry.get_character_stash_id(_destination_character_id)
		_:
			return -1


func get_destination_stash_type() -> StashRegistry.StashType:
	return _destination_stash_type


func get_destination_page_index() -> int:
	return _destination_page_index


func get_destination_character_id() -> int:
	return _destination_character_id


func get_destination_collection_id() -> int:
	return _destination_collection_id


func set_destination(stash_type: StashRegistry.StashType) -> void:
	if _destination_stash_type != stash_type:
		_destination_stash_type = stash_type
		destination_changed.emit(stash_type)

# ===== ItemTransfer =====

func store_active_page() -> void:
	var pd2_stash_id := StashRegistry.get_pd2_shared_stash_id()
	var goblin_stash_id := StashRegistry.get_goblin_main_stash_id()
	if pd2_stash_id == -1 or goblin_stash_id == -1:
		return
	var pd2_view := StashRegistry.get_stash_view(pd2_stash_id) as PagedStashView
	var items := pd2_view.get_items_in_page(_destination_page_index).duplicate()
	for item: D2Item in items:
		var transfer_record := CommandQueue.ItemTransferCommand.new(item, goblin_stash_id)
		CommandQueue.record_command(transfer_record)
	items_transferred.emit(goblin_stash_id)


func transfer_selection() -> void:
	if not can_transfer_selection() == SelectionTransferOutcome.ALLOWED:
		push_error("Cannot transfer selection")
		return
	transfer_items()


func transfer_items() -> void:
	var destination_stash_id := get_destination_stash_id()
	var stash_view := StashRegistry.get_stash_view(destination_stash_id)
	
	for item: D2Item in get_selected_items().duplicate():
		var placement := stash_view.get_placement(item, _destination_page_index)
		var transfer_record := CommandQueue.ItemTransferCommand.new(item, destination_stash_id, placement)
		CommandQueue.record_command(transfer_record)
	
	clear_selection()
	items_transferred.emit(destination_stash_id)


func can_transfer_selection() -> SelectionTransferOutcome:
	var destination_stash_id := get_destination_stash_id()
	var selected_items := get_selected_items()
	if not StashRegistry.has_stash(destination_stash_id) \
		or selected_items.is_empty():
			return SelectionTransferOutcome.NO_ITEMS
	if CommandQueue.is_command_queue_blocked():
		return SelectionTransferOutcome.QUEUE_BLOCKED
	var destination_view := StashRegistry.get_stash_view(destination_stash_id)
	if not destination_view.can_add_items(selected_items, _destination_page_index, D2Item.ItemLocation.STORED, D2Item.StoreLocation.STASH):
		return SelectionTransferOutcome.NO_SPACE
	for item: D2Item in selected_items:
		var stash_id := ItemRegistry.get_item_data_stash_id(item.item_id)
		var stash_type := StashRegistry.get_stash_type(stash_id)
		if stash_type == StashRegistry.StashType.PD2_SHARED and _destination_stash_type == stash_type:
			if item.equipped_id == _destination_page_index + 1:
				return SelectionTransferOutcome.SAME_DESTINATION
		elif stash_type in [StashRegistry.StashType.GOBLIN, StashRegistry.StashType.PD2_PERSONAL] and _destination_stash_type == stash_type:
			return SelectionTransferOutcome.SAME_DESTINATION
	return SelectionTransferOutcome.ALLOWED


func clear_goblin_stash() -> void:
	var clear_command := CommandQueue.StashClearCommand.new(StashRegistry.get_goblin_main_stash_id())
	CommandQueue.record_command(clear_command)
	clear_selection()
	stash_cleared.emit()


func import_plugy_items(item_lists: Array[D2ItemList]) -> void:
	var import_command := CommandQueue.ImportPlugyCommand.new(item_lists, StashRegistry.get_goblin_main_stash_id())
	CommandQueue.record_command(import_command)
	clear_selection()
	plugy_imported.emit()
