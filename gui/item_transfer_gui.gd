extends Control

@onready var item_info: ItemTooltip = %ItemInfo
@onready var transfer_button: Button = %TransferButton

# To stash
@onready var destination_stash_option: OptionButton = %DestinationOption
# Options
@onready var destination_option_tabs: TabContainer = %DestinationOptionTabs
@onready var page_option: OptionButton = %PageOption
@onready var character_option: OptionButton = %CharacterOption
@onready var collection_option: OptionButton = %CollectionOption
@onready var selected_label: Label = %SelectedLabel

var selected_item: D2Item

var _character_option_map: Dictionary[int, int] ## option_id -> character_id
var _collection_option_map: Dictionary[int, int] ## option_id -> collection_id


func _ready() -> void:
	ItemSelection.destination_changed.connect(_update_destination_labels)
	ItemSelection.active_page_changed.connect(_update_page_label)
	ItemSelection.active_page_changed.connect(_update_transfer_button.unbind(1))
	ItemSelection.active_character_changed.connect(_update_transfer_button.unbind(1))
	ItemSelection.selection_changed.connect(_update_item_info)
	
	StashRegistry.characters_registered.connect(_update_character_options)
	StashRegistry.goblin_registered.connect(_update_goblin_options)
	
	transfer_button.pressed.connect(ItemSelection.transfer_selection)
	destination_stash_option.item_selected.connect(_change_destination)
	page_option.item_selected.connect(_change_destination_page)
	character_option.item_selected.connect(_change_destination_character)
	
	_update_transfer_button()


func _update_character_options() -> void:
	character_option.clear()
	
	var character_names := StashRegistry.get_character_names()
	var character_ids := StashRegistry.get_character_ids()
	
	for i: int in character_names.size():
		character_option.add_item(character_names[i])
		_character_option_map[character_option.item_count - 1] = character_ids[i]
		if ItemSelection.get_destination_character_id() == -1:
			ItemSelection.set_destination_character(character_ids[i])


func _update_goblin_options() -> void:
	collection_option.clear()
	var names := StashRegistry.get_goblin_collection_names()
	var ids := StashRegistry.get_goblin_collection_ids()
	for i: int in ids.size():
		collection_option.add_item(names[i])
		_collection_option_map[i] = ids[i]
	if ItemSelection.get_destination_collection_id() == -1:
		ItemSelection.set_destination_collection(ids[0])


func _update_item_info() -> void:
	selected_item = ItemSelection.get_last_selected_item()
	item_info.update_tooltip(selected_item)
	var item_count := ItemSelection.get_selected_items().size()
	transfer_button.text = "Send (%d)" % ItemSelection.get_selected_items().size() if item_count > 1 else "Send"
	selected_label.text = "Selected (%d)" % item_count if item_count > 1 else "Selected"
	
	_update_transfer_button()


func _update_transfer_button() -> void:
	match ItemSelection.can_transfer_selection():
		ItemSelection.SelectionTransferOutcome.ALLOWED:
			var item_count := ItemSelection.get_selected_items().size()
			transfer_button.text = "Send (%d)" % ItemSelection.get_selected_items().size() if item_count > 1 else "Send"
			transfer_button.disabled = false
		ItemSelection.SelectionTransferOutcome.QUEUE_BLOCKED:
			transfer_button.text = "Pending PlugY import, save first"
			transfer_button.disabled = true
		ItemSelection.SelectionTransferOutcome.NO_ITEMS:
			transfer_button.text = "No selection"
			transfer_button.disabled = true
		ItemSelection.SelectionTransferOutcome.NO_SPACE:
			transfer_button.text = "No space"
			transfer_button.disabled = true
		ItemSelection.SelectionTransferOutcome.SAME_DESTINATION:
			transfer_button.text = "Cannot send to same stash"
			transfer_button.disabled = true
		_:
			transfer_button.text = "Cannot send"
			transfer_button.disabled = true


func _update_page_label(new_page: int) -> void:
	page_option.selected = 8 - new_page


func _update_destination_labels(new_stash_type: StashRegistry.StashType) -> void:
	match new_stash_type:
		StashRegistry.StashType.GOBLIN:
			destination_stash_option.select(0)
			destination_option_tabs.current_tab = 0
		StashRegistry.StashType.PD2_SHARED:
			destination_stash_option.select(1)
			destination_option_tabs.current_tab = 1
		StashRegistry.StashType.PD2_PERSONAL:
			destination_stash_option.select(2)
			destination_option_tabs.current_tab = 2
	_update_transfer_button()


func _change_destination(option_index: int) -> void:
	match option_index:
		0:
			ItemSelection.set_destination(StashRegistry.StashType.GOBLIN)
		1:
			ItemSelection.set_destination(StashRegistry.StashType.PD2_SHARED)
		2:
			ItemSelection.set_destination(StashRegistry.StashType.PD2_PERSONAL)


func _change_destination_page(option_index: int) -> void:
	ItemSelection.set_destination_page_index(8 - option_index)


func _change_destination_character(option_index: int) -> void:
	var character_id := _character_option_map[option_index]
	ItemSelection.set_destination_character(character_id)
