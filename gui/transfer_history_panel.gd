extends ScrollContainer

const FILE_FONT = preload("uid://cen8snwgwauy1")
const MAX_TRANSFER_LABELS := 20

@onready var add_container: VBoxContainer = %AddContainer
@onready var save_container: VBoxContainer = %SaveContainer


func _ready() -> void:
	clear_command_labels()


func update_command_labels(commands: Array[CommandQueue.BasicCommand]) -> void:
	clear_command_labels()
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
	label.text = "... and %d more items" % diff if diff > 1 else "... and 1 more item"
	add_container.add_child(label)


func add_command_label(command: CommandQueue.BasicCommand) -> void:
	if command is CommandQueue.ItemTransferCommand:
		_add_transfer_label(command)
	elif command is CommandQueue.StashClearCommand:
		_add_clear_stash_label()
	elif command is CommandQueue.ImportPlugyCommand:
		_add_import_label()


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
	transfer_label.text += _get_stash_name(command.destination_stash_id)
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
