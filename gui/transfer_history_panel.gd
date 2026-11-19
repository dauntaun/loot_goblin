extends ScrollContainer

const FILE_FONT = preload("uid://cen8snwgwauy1")
const MAX_TRANSFER_LABELS := 20

@onready var add_container: VBoxContainer = %AddContainer
@onready var save_container: VBoxContainer = %SaveContainer

var _update_scheduled: bool


func _ready() -> void:
	clear_command_labels()


func update_command_labels() -> void:
	if _update_scheduled:
		return

	_update_scheduled = true
	_rebuild_command_labels.call_deferred()


func _rebuild_command_labels() -> void:
	_update_scheduled = false
	clear_command_labels()
	
	var commands := CommandQueue.get_command_queue()

	# Annotate commands
	for i: int in mini(commands.size(), MAX_TRANSFER_LABELS):
		add_command_label(commands[i])

	var diff := commands.size() - MAX_TRANSFER_LABELS
	if diff > 0:
		_add_overflow_label(diff)

	# Annotate save files
	for file: BasicSaveFile in CommandQueue.get_involved_save_files():
		var filename := file.load_path.get_file()
		var label := Label.new()
		label.text = filename
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		label.add_theme_font_override("font", FILE_FONT)
		save_container.add_child(label)


func _add_overflow_label(diff: int) -> void:
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = "... and %d more changes" % diff if diff > 1 else "... and 1 more change"
	add_container.add_child(label)


func add_command_label(command: CommandQueue.BasicCommand) -> void:
	if command is CommandQueue.ItemTransferCommand:
		_add_transfer_label(command)
	elif command is CommandQueue.StashClearCommand:
		_add_clear_stash_label()
	elif command is CommandQueue.ImportPlugyCommand:
		_add_import_label()
	elif command is CommandQueue.AddCollectionCommand:
		_add_collection_label(command.collection_name)
	elif command is CommandQueue.RenameCollectionCommand:
		_rename_collection_label(command.new_name)
	elif command is CommandQueue.DeleteCollectionCommand:
		_delete_collection_label(command.collection.name)
	elif command is CommandQueue.MoveCollectionCommand:
		_move_collection_label(command.collection.name)


func _add_transfer_label(command: CommandQueue.ItemTransferCommand) -> void:
	var hbox := HBoxContainer.new()
	var item_label := Label.new()
	item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	item_label.text = command.item.item_name
	item_label.add_theme_color_override("font_color", D2Colors.get_item_color(command.item))
	hbox.add_child(item_label)
	var transfer_label := Label.new()
	transfer_label.text = _get_stash_name(command.source_stash_id) + "->"
	transfer_label.text += _get_stash_name(command.destination_data.stash_id)
	hbox.add_child(transfer_label)
	add_container.add_child(hbox)
	


func _add_import_label() -> void:
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = "PlugY import"
	add_container.add_child(label)


func _add_clear_stash_label() -> void:
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = "Clear stash"
	add_container.add_child(label)


func _add_collection_label(collection_name: String) -> void:
	var hbox := HBoxContainer.new()
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.text = "Add collection"
	hbox.add_child(label)
	var name_label := Label.new()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_label.text = collection_name
	hbox.add_child(name_label)
	add_container.add_child(hbox)


func _rename_collection_label(collection_name: String) -> void:
	var hbox := HBoxContainer.new()
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.text = "Rename collection"
	hbox.add_child(label)
	var name_label := Label.new()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_label.text = collection_name
	hbox.add_child(name_label)
	add_container.add_child(hbox)


func _delete_collection_label(collection_name: String) -> void:
	var hbox := HBoxContainer.new()
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.text = "Delete collection"
	hbox.add_child(label)
	var name_label := Label.new()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_label.text = collection_name
	hbox.add_child(name_label)
	add_container.add_child(hbox)


func _move_collection_label(collection_name: String) -> void:
	var hbox := HBoxContainer.new()
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.text = "Move collection"
	hbox.add_child(label)
	var name_label := Label.new()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_label.text = collection_name
	hbox.add_child(name_label)
	add_container.add_child(hbox)


func clear_command_labels() -> void:
	for child: Node in add_container.get_children():
		child.queue_free()
	for child: Node in save_container.get_children():
		child.queue_free()


func _get_stash_name(stash_id: int) -> String:
	var stash_type := StashRegistry.get_stash_type(stash_id)
	match stash_type:
		StashRegistry.StashType.GOBLIN:
			return "Stash"
		StashRegistry.StashType.PD2_SHARED:
			return "PD2"
		StashRegistry.StashType.PD2_PERSONAL:
			return "Char"
		_:
			return "PlugY"
