extends Control

@onready var transfer_button: Button = %TransferButton
@onready var item_info: ItemTooltip = %ItemInfo

@onready var toggle_single: Button = %ToggleSingle
@onready var toggle_bulk: Button = %ToggleBulk
@onready var destination_option: OptionButton = %DestinationOption
@onready var page_container: HBoxContainer = %PageOptionContainer
@onready var page_option: OptionButton = %PageOption
# Debug
@onready var item_debug: ItemDebugGUI = %ItemDebug

var selected_item: D2Item


func _ready() -> void:
	ItemSelection.destination_changed.connect(_update_destination_labels)
	ItemSelection.active_page_changed.connect(_update_destination_labels)
	ItemSelection.transfer_mode_changed.connect(_update_destination_labels)
	ItemSelection.selection_changed.connect(_update_item_info)
	
	transfer_button.pressed.connect(ItemSelection.transfer_selection)
	page_option.item_selected.connect(func(index: int): ItemSelection.set_destination_page_index(8 - index))
	destination_option.item_selected.connect(_change_destination)
	toggle_single.pressed.connect(ItemSelection.set_transfer_mode.bind(ItemSelection.TransferMode.SINGLE))
	toggle_bulk.pressed.connect(ItemSelection.set_transfer_mode.bind(ItemSelection.TransferMode.BULK))
	
	_update_transfer_button()


func _update_item_info() -> void:
	selected_item = ItemSelection.get_last_selected_item()
	item_info.update_tooltip(selected_item)
	item_debug.update_labels(selected_item)
	
	toggle_bulk.text = "All (%d)" % ItemSelection.get_bulk_selection().size()
	
	if ItemSelection.is_goblin_selected():
		destination_option.set_item_disabled(1, true)
	else:
		destination_option.set_item_disabled(1, false)
	
	_update_transfer_button()


func _update_transfer_button() -> void:
	if CommandQueue.is_command_queue_blocked():
		transfer_button.text = "Pending PlugY import, save first"
		transfer_button.disabled = true
	elif ItemSelection.get_selected_items().is_empty():
		transfer_button.text = "No selection"
		transfer_button.disabled = true
	elif ItemSelection.can_transfer_selection():
		transfer_button.text = "Send"
		transfer_button.disabled = false
	else:
		transfer_button.text = "Not enough space"
		transfer_button.disabled = true


func _increase_pd2_page() -> void:
	ItemSelection.set_destination_page_index(ItemSelection.get_destination_page_index() + 1)


func _decrease_pd2_page() -> void:
	ItemSelection.set_destination_page_index(ItemSelection.get_destination_page_index() - 1)


func _update_destination_labels() -> void:
	if ItemSelection.is_destination_goblin():
		destination_option.selected = 1
		page_container.hide()
	elif ItemSelection.is_destination_pd2_shared():
		destination_option.selected = 0
		page_container.show()
		page_option.selected = 8 - ItemSelection.get_destination_page_index()
	_update_transfer_button()


func _change_destination(option_index: int) -> void:
	if option_index == 0:
		ItemSelection.set_destination_stash(StashRegistry.StashType.PD2_SHARED)
	elif option_index == 1:
		ItemSelection.set_destination_stash(StashRegistry.StashType.GOBLIN)
	
	
