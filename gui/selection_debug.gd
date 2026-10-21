class_name SelectionDebugGUI
extends Control

@onready var selection_debug_destination_stash: Label = %SelectionDebugDestinationStash
@onready var selection_debug_destination_stash_id: Label = %SelectionDebugDestinationStashID
@onready var selection_debug_destination_collection: Label = %SelectionDebugDestinationCollection
@onready var selection_debug_destination_character: Label = %SelectionDebugDestinationCharacter
@onready var selection_debug_destination_page: Label = %SelectionDebugDestinationPage


func _ready() -> void:
	GlobalSettings.debug_enabled.connect(show_selection_debug)
	if not GlobalSettings.debug_mode:
		hide()


func show_selection_debug() -> void:
	show()
	clear_labels()
	ItemSelection.selection_changed.connect(update_labels)
	ItemSelection.destination_changed.connect(update_labels.unbind(1))
	ItemSelection.active_character_changed.connect(update_labels.unbind(1))
	ItemSelection.active_collection_changed.connect(update_labels.unbind(1))
	ItemSelection.active_page_changed.connect(update_labels.unbind(1))


func update_labels() -> void:
	var item := ItemSelection.get_last_selected_item()
	selection_debug_destination_stash.text = "dest_stash: %s" % StashRegistry.StashType.find_key(ItemSelection._destination_stash_type)
	selection_debug_destination_stash_id.text = "dest_stash_id: %d" % ItemSelection.get_destination_stash_id()
	selection_debug_destination_collection.text = "dest_goblin: %d" % ItemSelection._destination_collection_id
	selection_debug_destination_character.text = "dest_char: %d" % ItemSelection._destination_character_id
	selection_debug_destination_page.text = "dest_page: %d" % ItemSelection._destination_page_index


func clear_labels() -> void:
	selection_debug_destination_stash.text = "dest_stash:"
	selection_debug_destination_stash_id.text = "dest_stash_id:"
	selection_debug_destination_collection.text = "dest_goblin:"
	selection_debug_destination_character.text = "dest_char:"
	selection_debug_destination_page.text = "dest_page:"
