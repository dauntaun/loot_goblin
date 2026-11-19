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
	var cancel_command := false
	for prev_command: BasicCommand in _command_queue.duplicate():
		if prev_command.matches_with(new_command):
			if prev_command.is_redundant_with(new_command):
				cancel_command = true
				prev_command.undo_move_view()
				_command_queue.erase(prev_command)
				if _command_queue.is_empty():
					queue_undone.emit()
				if new_command.continue_redundancy_check():
					continue
				else:
					#command_queued.emit()
					return
			elif not cancel_command:
				prev_command.update_with(new_command)
				prev_command.execute_move_view()
				command_queued.emit()
				return
	if cancel_command:
		command_queued.emit()
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


func get_involved_save_files() -> Array[BasicSaveFile]:
	var saves: Array[BasicSaveFile]
	for command: BasicCommand in _command_queue:
		var destination_save := command.destination_save
		if not saves.has(destination_save):
			saves.append(destination_save)
		if command is CommandQueue.ItemTransferCommand:
			var source_save: BasicSaveFile = command.source_save
			if not saves.has(source_save):
				saves.append(source_save)
	return saves


@abstract class BasicCommand:
	var destination_save: BasicSaveFile
	
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
	
	func continue_redundancy_check() -> bool:
		return false


class ImportPlugyCommand extends BasicCommand:
	var plugy_items: Array[D2Item]
	var source_data: Array[D2ItemList]
	var destination_data: D2ItemList
	var destination_view: BasicStashView
	
	
	func _init(item_lists: Array[D2ItemList], to_stash_id: int) -> void:
		source_data = item_lists
		destination_save = StashRegistry.get_stash_save(to_stash_id)
		destination_view = StashRegistry.get_stash_view(to_stash_id)
		destination_data = StashRegistry.get_stash_data(to_stash_id)
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
	var destination_data: D2ItemList
	var destination_view: BasicStashView
	
	
	func _init(to_stash_id: int) -> void:
		destination_save = StashRegistry.get_stash_save(to_stash_id)
		destination_view = StashRegistry.get_stash_view(to_stash_id)
		destination_data = StashRegistry.get_stash_data(to_stash_id)
		stash_items = destination_data.get_items()
	
	
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


class AddCollectionCommand extends BasicCommand:
	var collection: GoblinSaveFile.GoblinCollection
	var collection_name
	
	func _init(init_name: String) -> void:
		collection_name = init_name
		destination_save = StashRegistry.get_goblin_save_file()
	
	
	func execute_move_view() -> void:
		var new_data := PackedByteArray()
		new_data.resize(74)
		collection = GoblinSaveFile.GoblinCollection.new(0, new_data)
		collection.name = collection_name
		collection.write_headers()
		collection.init_item_list()
		
		StashRegistry.register_new_collection(collection)
	
	
	func undo_move_view() -> void:
		StashRegistry.unregister_collection(collection)
	
	
	func execute_move_data() -> void:
		destination_save = destination_save as GoblinSaveFile
		destination_save.append_collection(collection)
	
	
	func validate_move_data() -> bool:
		return true
	
	
	func is_blocking() -> bool:
		return false
	
	
	#func matches_with(new_command: BasicCommand) -> bool:
		#if new_command is DeleteCollectionCommand:
			#return collection == new_command.collection
		#return false
	#
	#
	#func is_redundant_with(new_command: BasicCommand) -> bool:
		#return matches_with(new_command)


class RenameCollectionCommand extends BasicCommand:
	var collection: GoblinSaveFile.GoblinCollection
	var new_name: String
	var old_name: String
	
	
	func _init(init_id: int, init_name: String) -> void:
		collection = StashRegistry.get_goblin_collection(init_id)
		new_name = init_name
		old_name = collection.name
		destination_save = StashRegistry.get_goblin_save_file()
	
	
	func execute_move_view() -> void:
		collection.name = new_name
		StashRegistry.reregister_collection_name(collection)
	
	
	func undo_move_view() -> void:
		collection.name = old_name
		StashRegistry.reregister_collection_name(collection)
	
	
	func execute_move_data() -> void:
		collection.write_name()
	
	
	func validate_move_data() -> bool:
		return true
	
	
	func is_blocking() -> bool:
		return false
	
	
	#func matches_with(new_command: BasicCommand) -> bool:
		#if new_command is RenameCollectionCommand:
			#return collection == new_command.collection
		#elif new_command is DeleteCollectionCommand:
			#return collection == new_command.collection
		#return false
	#
	#
	#func is_redundant_with(new_command: BasicCommand) -> bool:
		#if new_command is RenameCollectionCommand:
			#return old_name == new_command.new_name
		#elif new_command is DeleteCollectionCommand:
			#return collection == new_command.collection
		#return false
	#
	#
	#func update_with(new_command: BasicCommand) -> void:
		#new_name = new_command.new_name


class DeleteCollectionCommand extends BasicCommand:
	var collection: GoblinSaveFile.GoblinCollection
	var collection_id: int
	var collection_index: int
	
	
	func _init(init_id: int) -> void:
		collection_id = init_id
		collection = StashRegistry.get_goblin_collection(collection_id)
		collection_index = StashRegistry.get_goblin_collection_ids().find(collection.collection_id)
		destination_save = StashRegistry.get_goblin_save_file()
	
	
	func execute_move_view() -> void:
		StashRegistry.unregister_collection(collection)
	
	
	func undo_move_view() -> void:
		StashRegistry.register_new_collection(collection)
		StashRegistry.reregister_collection_index(collection, collection_index)
	
	
	func execute_move_data() -> void:
		destination_save = destination_save as GoblinSaveFile
		destination_save.delete_collection(collection)
	
	
	func validate_move_data() -> bool:
		return true
	
	
	func is_blocking() -> bool:
		return false
	
	
	#func matches_with(new_command: BasicCommand) -> bool:
		#if new_command is AddCollectionCommand:
			#return new_command.collection == collection
		#else:
			#return false
	#
	#
	#func is_redundant_with(new_command: BasicCommand) -> bool:
		#return matches_with(new_command)
	#
	#
	#func continue_redundancy_check() -> bool:
		#return true


class MoveCollectionCommand extends BasicCommand:
	var collection: GoblinSaveFile.GoblinCollection
	var new_index: int
	var old_index: int
	
	
	func _init(init_id: int, init_index: int) -> void:
		collection = StashRegistry.get_goblin_collection(init_id)
		new_index = init_index
		old_index = StashRegistry.get_goblin_collection_ids().find(collection.collection_id)
		destination_save = StashRegistry.get_goblin_save_file()
	
	
	func execute_move_view() -> void:
		StashRegistry.reregister_collection_index(collection, new_index)
	
	
	func undo_move_view() -> void:
		StashRegistry.reregister_collection_index(collection, old_index)
	
	
	func execute_move_data() -> void:
		destination_save = destination_save as GoblinSaveFile
		destination_save.reorder_collection(collection, new_index)
	
	
	func validate_move_data() -> bool:
		return true
	
	
	func is_blocking() -> bool:
		return false
	
	
	#func matches_with(new_command: BasicCommand) -> bool:
		#if new_command is MoveCollectionCommand:
			#return collection == new_command.collection
		#elif new_command is DeleteCollectionCommand:
			#return collection == new_command.collection
		#return false
	#
	#
	#func is_redundant_with(new_command: BasicCommand) -> bool:
		#if new_command is MoveCollectionCommand:
			#return old_index == new_command.new_index
		#elif new_command is DeleteCollectionCommand:
			#return collection == new_command.collection
		#return false
	#
	#
	#func update_with(new_command: BasicCommand) -> void:
		#new_index = new_command.new_index


class ItemTransferCommand extends BasicCommand:
	var item: D2Item
	var source_save: BasicSaveFile
	var source_stash_id: int
	var source_placement: ItemPlacement
	var source_view: BasicStashView
	var source_data: D2ItemList
	var destination_placement: ItemPlacement
	var destination_data: D2ItemList
	var destination_view: BasicStashView
	
	
	func _init(
		for_item: D2Item,
	 	to_stash_id: int,
		placement: ItemPlacement = null) -> void:
		
		item = for_item
		source_stash_id = ItemRegistry.get_item_data_stash_id(item.item_id)
		source_placement = ItemPlacement.from_item(item) # Snapshot for undo
		source_save = StashRegistry.get_stash_save(source_stash_id)
		var stash_id := ItemRegistry.get_item_data_stash_id(item.item_id)
		source_data = StashRegistry.get_stash_data(stash_id)
		destination_save = StashRegistry.get_stash_save(to_stash_id)
		destination_view = StashRegistry.get_stash_view(to_stash_id)
		destination_data = StashRegistry.get_stash_data(to_stash_id)
		destination_placement = placement
	
	
	func is_redundant_with(new_command: BasicCommand) -> bool:
		new_command = new_command as ItemTransferCommand
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
		destination_save = new_command.destination_save
		destination_data = new_command.destination_data
		destination_view = new_command.destination_view
		destination_placement = new_command.destination_placement
	
	
	func execute_move_view() -> void:
		if source_view == null:
			source_view = _get_current_view() # snapshot only once

		var current_view := _get_current_view()
		current_view.remove_item(item)

		if destination_placement:
			destination_placement.apply_to_item(item)
		destination_view.add_item(item)
	
	
	func undo_move_view() -> void:
		# Restore view
		destination_view.remove_item(item)
		# Restore position
		source_placement.apply_to_item(item)
		source_view.add_item(item)
	
	
	func execute_move_data() -> void:
		if source_data != destination_data:
			var item_bytes := source_data.extract_item_bytes(item)
			destination_data.add_item_bytes(item, item_bytes)
		if not source_placement.matches_item(item):
			destination_data.write_current_item_position(item)
	
	
	func validate_move_data() -> bool:
		return source_data.has_item_bytes(item)
	
	
	func _get_current_view() -> BasicStashView:
		var stash_id := ItemRegistry.get_item_view_stash_id(item.item_id)
		return StashRegistry.get_stash_view(stash_id)
