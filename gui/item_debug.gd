class_name ItemDebugGUI
extends Control

@onready var item_debug_stash: Label = %ItemDebugStash
@onready var item_debug_id: Label = %ItemDebugID
@onready var item_debug_start: Label = %ItemDebugStart
@onready var item_debug_length: Label = %ItemDebugLength
@onready var item_debug_location: Label = %ItemDebugLocation
@onready var item_debug_store: Label = %ItemDebugStore
@onready var item_debug_equipped: Label = %ItemDebugEquipped
@onready var item_debug_coord: Label = %ItemDebugCoord


func _read() -> void:
	clear_labels()


func update_labels(item: D2Item) -> void:
	if not item:
		clear_labels()
		return
	item_debug_stash.text = "source: %s" % StashRegistry.StashType.find_key(ItemRegistry.get_item_stash(item.item_id))
	item_debug_id.text = "item_id: %d" % item.item_id
	item_debug_start.text = "start_byte: %d" % item.start_byte
	item_debug_length.text = "length: %d" % item.length
	item_debug_location.text = "location_id: %s" % D2Item.ItemLocation.find_key(item.location_id)
	item_debug_store.text = "store_id: %s" % D2Item.StoreLocation.find_key(item.store_id)
	item_debug_equipped.text = "equipped_id: %d" % item.equipped_id
	item_debug_coord.text = "coord: (%d, %d)" % [item.x_coord, item.y_coord]


func clear_labels() -> void:
	item_debug_stash.text = "source:"
	item_debug_id.text = "item_id:"
	item_debug_start.text = "start_byte:"
	item_debug_length.text = "length:"
	item_debug_location.text = "location_id:"
	item_debug_store.text = "store_id:"
	item_debug_equipped.text = "equipped_id:"
	item_debug_coord.text = "coord:"
