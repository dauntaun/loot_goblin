extends ScrollContainer

const MAX_TRANSFER_LABELS := 20

@onready var add_container: VBoxContainer = %AddContainer
@onready var goblin_file_label: Label = %GoblinFileLabel
@onready var pd2_file_label: Label = %Pd2FileLabel


func _ready() -> void:
	clear_command_labels()


func update_command_labels(commands: Array[CommandQueue.BasicCommand]) -> void:
	clear_command_labels()
	for i: int in mini(commands.size(), MAX_TRANSFER_LABELS):
		add_command_label(commands[i])
	var diff := commands.size() - MAX_TRANSFER_LABELS
	if diff > 0:
		_add_overflow_label(diff)
	# Annotate file names
	var goblin_save := StashRegistry.get_save_file(StashRegistry.StashType.GOBLIN)
	var pd2_save := StashRegistry.get_save_file(StashRegistry.StashType.PD2_SHARED)
	if goblin_save:
		goblin_file_label.text = goblin_save.load_path.get_file()
	else:
		goblin_file_label.text = ""
	if pd2_save:
		pd2_file_label.text = pd2_save.load_path.get_file()
	else:
		pd2_file_label.text = ""


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
	transfer_label.text = _get_stash_name(command.source_stash) + "->"
	transfer_label.text += _get_stash_name(command.destination_stash)
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


func _get_stash_name(stash_type: StashRegistry.StashType) -> String:
	if stash_type == StashRegistry.StashType.GOBLIN:
		return "Stash"
	elif stash_type == StashRegistry.StashType.PD2_SHARED:
		return "PD2"
	else:
		return "PlugY"
