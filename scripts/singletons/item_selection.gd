# ItemSelection
extends Node

enum TransferMode {SINGLE, BULK}
# Source changed
signal selection_changed
# Destination changed
signal destination_changed
signal transfer_mode_changed
signal active_page_changed
# Transfer occurred
signal items_transferred(from: StashRegistry.StashType, to: StashRegistry.StashType)
signal stash_cleared
signal plugy_imported

# Source state
var _selected_item: D2Item
var _bulk_selection: Array[D2Item]
var _source_stash: StashRegistry.StashType
# Destination state
var _destination_stash: StashRegistry.StashType
var _destination_page_index: int
var _transfer_mode: TransferMode


func set_selection(item: D2Item, stash: StashRegistry.StashType, bulk_items: Array[D2Item] = []) -> void:
	if _selected_item != item or _source_stash != stash or _bulk_selection != bulk_items:
		_selected_item = item
		_bulk_selection = bulk_items
		if stash == StashRegistry.StashType.GOBLIN:
			set_destination_stash(StashRegistry.StashType.PD2_SHARED)
		elif stash == StashRegistry.StashType.PD2_SHARED and \
			_source_stash in [StashRegistry.StashType.GOBLIN, StashRegistry.StashType.UNKNOWN]:
			set_destination_stash(StashRegistry.StashType.GOBLIN)
		_source_stash = stash
		selection_changed.emit()


func clear_selection() -> void:
	if _selected_item:
		_selected_item = null
		_bulk_selection = []
		selection_changed.emit()


func get_last_selected_item() -> D2Item:
	return _selected_item


func get_bulk_selection() -> Array[D2Item]:
	return _bulk_selection


func get_selected_items() -> Array[D2Item]:
	if _transfer_mode == TransferMode.SINGLE:
		if _selected_item:
			return [_selected_item]
		else:
			return []
	else:
		return _bulk_selection


func get_source_stash_type() -> StashRegistry.StashType:
	return _source_stash


func is_goblin_selected() -> bool:
	return _source_stash == StashRegistry.StashType.GOBLIN


func is_pd2_shared_selected() -> bool:
	return _source_stash == StashRegistry.StashType.PD2_SHARED


func is_pd2_personal_selected() -> bool:
	return _source_stash == StashRegistry.StashType.PD2_PERSONAL


func is_pd2_materials_selected() -> bool:
	return _source_stash == StashRegistry.StashType.PD2_MATERIALS


func set_destination_page_index(page_index: int) -> void:
	page_index = clamp(page_index, 0, 8)
	if _destination_page_index != page_index:
		_destination_page_index = page_index
		active_page_changed.emit()


func get_destination_page_index() -> int:
	return _destination_page_index


func set_destination_stash(new_stash: StashRegistry.StashType) -> void:
	if _destination_stash != new_stash:
		_destination_stash = new_stash
		destination_changed.emit()


func is_destination_goblin() -> bool:
	return _destination_stash == StashRegistry.StashType.GOBLIN


func is_destination_pd2_shared() -> bool:
	return _destination_stash == StashRegistry.StashType.PD2_SHARED


func set_transfer_mode(new_mode: TransferMode) -> void:
	if _transfer_mode != new_mode:
		_transfer_mode = new_mode
		transfer_mode_changed.emit()

# ===== ItemTransfer =====

func store_active_page() -> void:
	var pd2_view := StashRegistry.get_stash_view(StashRegistry.StashType.PD2_SHARED) as PagedStashView
	if pd2_view:
		var items := pd2_view.get_items_in_page(_destination_page_index).duplicate()
		for item: D2Item in items:
			var transfer_record := CommandQueue.ItemTransferCommand.new(item, StashRegistry.StashType.PD2_SHARED, StashRegistry.StashType.GOBLIN)
			CommandQueue.record_command(transfer_record)
			items_transferred.emit(StashRegistry.StashType.PD2_SHARED, StashRegistry.StashType.GOBLIN)


func transfer_selection() -> void:
	if not can_transfer_selection():
		push_error("Cannot transfer selection")
		return
	transfer_items()


func transfer_items() -> void:
	var stash_view := StashRegistry.get_stash_view(_destination_stash)
	
	for item: D2Item in get_selected_items().duplicate():
		var placement := stash_view.get_placement(item, _destination_page_index)
		var transfer_record := CommandQueue.ItemTransferCommand.new(item, _source_stash, _destination_stash, placement)
		CommandQueue.record_command(transfer_record)
	
	clear_selection()
	items_transferred.emit(_source_stash, _destination_stash)


func can_transfer_selection() -> bool:
	var from_stash := StashRegistry.get_stash_entry(_source_stash)
	var to_stash := StashRegistry.get_stash_entry(_destination_stash)
	
	if not from_stash or not to_stash or get_selected_items().is_empty():
		return false
	if CommandQueue.is_command_queue_blocked():
		return false
	if not to_stash.view.can_add_items(get_selected_items(), _destination_page_index):
		return false
	else:
		return true


func clear_goblin_stash() -> void:
	var clear_command := CommandQueue.StashClearCommand.new(StashRegistry.StashType.GOBLIN)
	CommandQueue.record_command(clear_command)
	clear_selection()
	stash_cleared.emit()


func import_plugy_items(item_lists: Array[D2ItemList]) -> void:
	var import_command := CommandQueue.ImportPlugyCommand.new(item_lists, StashRegistry.StashType.GOBLIN)
	CommandQueue.record_command(import_command)
	clear_selection()
	plugy_imported.emit()
