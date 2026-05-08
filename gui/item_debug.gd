class_name ItemDebugGUI
extends Control

@onready var item_debug_data: Label = %ItemDebugData
@onready var item_debug_data_id: Label = %ItemDebugDataID
@onready var item_debug_view: Label = %ItemDebugView
@onready var item_debug_view_id: Label = %ItemDebugViewID
@onready var item_debug_id: Label = %ItemDebugID
@onready var item_debug_start: Label = %ItemDebugStart
@onready var item_debug_length: Label = %ItemDebugLength
@onready var item_debug_location: Label = %ItemDebugLocation
@onready var item_debug_store: Label = %ItemDebugStore
@onready var item_debug_equipped: Label = %ItemDebugEquipped
@onready var item_debug_coord: Label = %ItemDebugCoord
@onready var item_debug_version: Label = %ItemDebugVersion


func _ready() -> void:
	if not GlobalSettings.debug_mode:
		hide()
		return
	clear_labels()
	ItemSelection.selection_changed.connect(update_labels)


func update_labels() -> void:
	var item := ItemSelection._selected_item
	if not item:
		clear_labels()
		return
	var data_stash_id := ItemRegistry.get_item_data_stash_id(item.item_id)
	var data_stash_type := StashRegistry.get_stash_type(data_stash_id)
	item_debug_data.text = "data: %s" % StashRegistry.StashType.find_key(data_stash_type)
	item_debug_data_id.text = "data_id: %d" % data_stash_id
	var view_stash_id := ItemRegistry.get_item_view_stash_id(item.item_id)
	var view_stash_type := StashRegistry.get_stash_type(view_stash_id)
	item_debug_view.text = "view: %s" % StashRegistry.StashType.find_key(view_stash_type)
	item_debug_view_id.text = "view_id %d" % view_stash_id
	item_debug_id.text = "item_id: %d" % item.item_id
	item_debug_start.text = "start_offset: %d" % item.start_offset
	item_debug_length.text = "length: %d" % item.length
	item_debug_location.text = "location_id: %s" % D2Item.ItemLocation.find_key(item.location_id)
	item_debug_store.text = "store_id: %s" % D2Item.StoreLocation.find_key(item.store_id)
	item_debug_equipped.text = "equipped_id: %d" % item.equipped_id
	item_debug_coord.text = "coord: (%d, %d)" % [item.x_coord, item.y_coord]
	item_debug_version.text = "ver: %s" % D2Item.ItemVersion.find_key(item.item_version)


func clear_labels() -> void:
	item_debug_data.text = "data:"
	item_debug_data_id.text = "data_id:"
	item_debug_view.text = "view:"
	item_debug_view_id.text = "view_id:"
	item_debug_id.text = "item_id:"
	item_debug_start.text = "start_byte:"
	item_debug_length.text = "length:"
	item_debug_location.text = "location_id:"
	item_debug_store.text = "store_id:"
	item_debug_equipped.text = "equipped_id:"
	item_debug_coord.text = "coord:"
	item_debug_version.text = "ver:"
