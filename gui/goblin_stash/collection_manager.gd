class_name CollectionManager
extends Control

var _pending_rename: bool

@onready var _tree: Tree = %Tree
@onready var _rename_button: Button = %RenameButton
@onready var _remove_button: Button = %RemoveButton
@onready var _add_button: Button = %AddButton


func _ready() -> void:
	_rename_button.disabled = true
	_remove_button.disabled = true
	_rename_button.pressed.connect(_rename_selected_collection)
	_add_button.pressed.connect(_add_new_collection)
	_remove_button.pressed.connect(_remove_collection)
	
	_tree.set_column_title(0, "Collection")
	_tree.set_column_title(1, "Items")
	_tree.set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	_tree.set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	_tree.set_column_expand_ratio(0, 3)
	_tree.item_edited.connect(_on_collection_renamed)
	_tree.item_selected.connect(_on_item_selected)


func refresh() -> void:
	var collection_ids := StashRegistry.get_all_collection_stash_ids()
	var collection_names := StashRegistry.get_goblin_collection_names()
	_tree.clear()
	_tree.create_item() # Root
	for i: int in collection_ids.size():
		var collection_data := StashRegistry.get_stash_data(collection_ids[i])
		var collection_name := collection_names[i]
		var row := _tree.create_item()
		row.set_text(0, collection_name)
		row.set_text(1, str(collection_data.get_item_count()))
		row.set_metadata(0, collection_ids[i])


func _add_new_collection() -> void:
	var row := _tree.create_item()
	row.set_text(0, "New Collection")
	row.set_text(1, "0")
	row.select(0)
	_pending_rename = true
	_rename_selected_collection()


func _rename_selected_collection() -> void:
	_tree.grab_focus(true)
	var row := _tree.get_selected()
	row.set_editable(0, true)
	var input := InputEventAction.new()
	input.action = "ui_accept"
	input.pressed = true
	await get_tree().physics_frame
	Input.parse_input_event(input)


func _on_collection_renamed() -> void:
	var row := _tree.get_selected()
	row.set_editable(0, false)
	var chosen_name := row.get_text(0)
	if _pending_rename:
		var add_collection_record := CommandQueue.AddCollectionCommand.new(chosen_name)
		CommandQueue.record_command(add_collection_record)
		row.set_metadata(0, StashRegistry.get_goblin_collection_ids().back())
	else:
		var collection_id: int = row.get_metadata(0)
		var rename_collection_record := CommandQueue.RenameCollectionCommand.new(collection_id, chosen_name)
		CommandQueue.record_command(rename_collection_record)
	_pending_rename = false


func _on_item_selected() -> void:
	var row := _tree.get_selected()
	var main_index := row.get_index() == 0
	_rename_button.disabled = main_index
	_remove_button.disabled = main_index


func _remove_collection() -> void:
	var row := _tree.get_selected()
	var collection_id: int = row.get_metadata(0)
	var delete_collection_record := CommandQueue.DeleteCollectionCommand.new(collection_id)
	CommandQueue.record_command(delete_collection_record)
	row.free()
	_rename_button.disabled = true
	_remove_button.disabled = true
