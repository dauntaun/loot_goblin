# CommandQueue
extends Node

signal command_queued
signal queue_undone
signal queue_committed
signal queue_blocked

var _command_queue: Array[BasicCommand]
var _queue_blocked: bool


func record_command(new_command: BasicCommand) -> void:
	if _queue_blocked:
		return
	
	if new_command.is_blocking():
		if not _command_queue.is_empty():
			return
		_queue_blocked = true
		queue_blocked.emit()
	
	# Check previous commands
	for prev_command: BasicCommand in _command_queue:
		if prev_command.matches_with(new_command):
			if prev_command.is_redundant_with(new_command):
				prev_command.undo_move_view()
				_command_queue.erase(prev_command)
				if _command_queue.is_empty():
					queue_undone.emit()
				return
			else:
				prev_command.update_with(new_command)
				prev_command.execute_move_view()
				return
	# Else queue new command
	new_command.execute_move_view()
	_command_queue.append(new_command)
	command_queued.emit()


func is_command_queue_blocked() -> bool:
	return _queue_blocked


func is_command_queue_clear() -> bool:
	return _command_queue.is_empty()


func get_command_queue() -> Array[BasicCommand]:
	return _command_queue


func commit_queue() -> void:
	# Check integrity
	for command: BasicCommand in _command_queue:
		if not command.validate_move_data():
			push_error("Source data does not have item bytes, cancelling all transfers")
			return
	# Committing bytes
	for command: BasicCommand in _command_queue:
		command.execute_move_data()
	_command_queue.clear()
	_queue_blocked = false
	queue_committed.emit()


func undo_queue() -> void:
	var queue = _command_queue.duplicate()
	queue.reverse() # LIFO
	for command: BasicCommand in queue:
		command.undo_move_view()
	_queue_blocked = false
	_command_queue.clear()
	queue_undone.emit()


@abstract class BasicCommand:
	var destination_stash: StashRegistry.StashType
	var destination_data: D2ItemList
	var destination_view: BasicStashView
	
	@abstract func execute_move_view() -> void
	@abstract func execute_move_data() -> void
	@abstract func undo_move_view() -> void
	@abstract func validate_move_data() -> bool
	
	@warning_ignore("unused_parameter")
	func matches_with(new_command: BasicCommand) -> bool:
		return false
	
	@warning_ignore("unused_parameter")
	func update_with(new_command: BasicCommand) -> void:
		pass
	
	func is_blocking() -> bool:
		return false
	
	@warning_ignore("unused_parameter")
	func is_redundant_with(new_command: BasicCommand) -> bool:
		return false
	
	func cleanup() -> void:
		pass


class ImportPlugyCommand extends BasicCommand:
	var plugy_items: Array[D2Item]
	var source_data: Array[D2ItemList]
	
	
	func _init(item_lists: Array[D2ItemList], to_stash: StashRegistry.StashType) -> void:
		source_data = item_lists
		destination_stash = to_stash
		var stash := StashRegistry.get_stash_entry(to_stash)
		destination_view = stash.view
		destination_data = stash.data
		for data: D2ItemList in source_data:
			plugy_items.append_array(data._items)
	
	
	func execute_move_view() -> void:
		destination_view.import_items(plugy_items)
	
	
	func undo_move_view() -> void:
		for item: D2Item in plugy_items:
			destination_view.remove_item(item)
	
	
	func execute_move_data() -> void:
		destination_data.import_item_lists(source_data)
	
	
	func validate_move_data() -> bool:
		return true
	
	
	func is_blocking() -> bool:
		return true
	


class StashClearCommand extends BasicCommand:
	var stash_items: Array[D2Item]
	
	
	func _init(to_stash: StashRegistry.StashType) -> void:
		destination_stash = to_stash
		var stash := StashRegistry.get_stash_entry(to_stash)
		destination_data = stash.data
		destination_view = stash.view
		stash_items = destination_data._items
	
	
	func execute_move_view() -> void:
		destination_view.clear_list()
	
	
	func undo_move_view() -> void:
		for item: D2Item in stash_items:
			destination_view.add_item(item)
	
	
	func execute_move_data() -> void:
		destination_data.clear_list()
	
	
	func validate_move_data() -> bool:
		return stash_items == destination_data._items
	
	
	func is_blocking() -> bool:
		return false
	
	
	func matches_with(new_command: BasicCommand) -> bool:
		if new_command is StashClearCommand:
			if new_command.destination_data == destination_data:
				return true
		return false
	
	
	func update_with(new_command: BasicCommand) -> void:
		destination_data = new_command.destination_data


class ItemTransferCommand extends BasicCommand:
	var item: D2Item
	var source_stash: StashRegistry.StashType
	var source_view: BasicStashView
	var destination_placement: ItemPlacement
	var source_placement: ItemPlacement
	
	
	func _init(
		for_item: D2Item,
		from_stash: StashRegistry.StashType,
	 	to_stash: StashRegistry.StashType,
		placement: ItemPlacement = null) -> void:
		
		item = for_item
		source_placement = ItemPlacement.from_item(item) # Snapshot for undo
		source_stash = from_stash
		destination_stash = to_stash
		var stash := StashRegistry.get_stash_entry(to_stash)
		destination_view = stash.view
		destination_data = stash.data
		destination_placement = placement
	
	
	func is_redundant_with(new_command: BasicCommand) -> bool:
		new_command = new_command as ItemTransferCommand
		var source_data := _get_source_data()
		if source_data == new_command.destination_data:
			if not new_command.destination_placement:
				return true
			elif source_placement.matches_placement(new_command.destination_placement):
				return true
			else:
				return false
		return false
	
	
	func matches_with(new_command: BasicCommand) -> bool:
		return new_command is ItemTransferCommand \
			and new_command.item == item
	
	
	func update_with(new_command: BasicCommand) -> void:
		new_command = new_command as ItemTransferCommand
		destination_stash = new_command.destination_stash
		destination_data = new_command.destination_data
		destination_view = new_command.destination_view
		destination_placement = new_command.destination_placement
	
	
	func execute_move_view() -> void:
		source_view = _get_current_view() # Snapshot for undo
		source_view.remove_item(item)
		if destination_placement:
			destination_placement.apply_to_item(item)
		destination_view.add_item(item)
	
	
	func undo_move_view() -> void:
		# Restore position
		source_placement.apply_to_item(item)
		# Restore view
		destination_view.remove_item(item)
		source_view.add_item(item)
	
	
	func execute_move_data() -> void:
		var source_data := _get_source_data()
		if source_data != destination_data:
			var item_bytes := source_data.extract_item_bytes(item)
			destination_data.add_item_bytes(item, item_bytes)
		if not source_placement.matches_item(item):
			destination_data.write_current_item_position(item)
	
	
	func validate_move_data() -> bool:
		return _get_source_data().has_item_bytes(item)
	
	
	func _get_source_data() -> D2ItemList:
		return ItemRegistry.get_item_data(item.item_id)
	
	
	func _get_current_view() -> BasicStashView:
		return ItemRegistry.get_item_view(item.item_id)
