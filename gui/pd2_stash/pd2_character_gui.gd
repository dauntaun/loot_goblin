class_name PD2CharacterGUI
extends Control

@onready var character_select: CharacterSelectGUI = %CharacterSelect
@onready var char_inventory: StashPageGUI = %CharInventory
@onready var cube_inventory: StashPageGUI = %CubeInventory
@onready var char_equip: CharacterEquipGUI = %Character
@onready var merc_equip: CharacterEquipGUI = %Mercenary
@onready var pd2_stash: PD2StashGUI = %PD2Stash

var _current_character_id := -1
var _char_view: CharacterStashView
var _merc_view: CharacterStashView


func _ready() -> void:
	character_select.character_selected.connect(_init_character_inventory)
	
	char_inventory.item_selected.connect(_on_item_selected.bind("inventory"))
	cube_inventory.item_selected.connect(_on_item_selected.bind("cube"))
	char_equip.item_selected.connect(_on_item_selected.bind("equip"))
	merc_equip.item_selected.connect(_on_item_selected.bind("merc"))


func _init_character_inventory(character_id: int) -> void:
	if _current_character_id == character_id:
		return
	if _current_character_id != -1:
		_cleanup_connections()
	var char_stash_id := StashRegistry.get_character_stash_id(character_id)
	var char_stash_view := StashRegistry.get_stash_view(char_stash_id)
	char_stash_view.item_added.connect(_on_item_added_in_char_view)
	char_stash_view.item_removed.connect(_on_item_removed_from_char_view)
	_char_view = char_stash_view
	var equipped_items := char_stash_view.get_equipped_items()
	var inventory_items := char_stash_view.get_inventory_items()
	var cube_items := char_stash_view.get_cube_items()
	pd2_stash.init_personal_page(char_stash_view)
	char_equip.init_equipped_items(equipped_items)
	char_inventory.init_page(inventory_items)
	cube_inventory.init_page(cube_items)
	
	var merc_stash_id := StashRegistry.get_mercenary_stash_id(character_id)
	if merc_stash_id != -1:
		var merc_stash_view := StashRegistry.get_stash_view(merc_stash_id)
		merc_stash_view.item_added.connect(_on_item_added_in_merc_view)
		merc_stash_view.item_removed.connect(_on_item_removed_from_merc_view)
		_merc_view = merc_stash_view
		var merc_items := merc_stash_view.get_equipped_items()
		merc_equip.init_equipped_items(merc_items)
	
	_current_character_id = character_id


func _on_item_selected(item: D2Item, inventory_case: String) -> void:
	match inventory_case:
		"inventory":
			var bulk_items := _char_view.get_inventory_items()
			ItemSelection.set_selection(item, bulk_items)
			char_inventory.select_item(item)
		"cube":
			var bulk_items := _char_view.get_cube_items()
			ItemSelection.set_selection(item, bulk_items)
			cube_inventory.select_item(item)
		"equip":
			var bulk_items := _char_view.get_equipped_items()
			ItemSelection.set_selection(item, bulk_items)
			char_equip.select_item(item)
		"merc":
			var bulk_items := _merc_view.get_equipped_items()
			ItemSelection.set_selection(item, bulk_items)
			merc_equip.select_item(item)


func _on_item_added_in_char_view(item: D2Item) -> void:
	match item.location_id:
		D2Item.ItemLocation.STORED:
			match item.store_id:
				D2Item.StoreLocation.INVENTORY:
					char_inventory.add_item_rect(item)
				D2Item.StoreLocation.CUBE:
					cube_inventory.add_item_rect(item)
		D2Item.ItemLocation.EQUIPPED:
			char_equip.add_item_rect(item)


func _on_item_removed_from_char_view(item: D2Item) -> void:
	match item.location_id:
		D2Item.ItemLocation.STORED:
			match item.store_id:
				D2Item.StoreLocation.INVENTORY:
					char_inventory.remove_item(item)
				D2Item.StoreLocation.CUBE:
					cube_inventory.remove_item(item)
		D2Item.ItemLocation.EQUIPPED:
			char_equip.remove_item(item)


func _on_item_added_in_merc_view(item: D2Item) -> void:
	merc_equip.add_item_rect(item)


func _on_item_removed_from_merc_view(item: D2Item) -> void:
	merc_equip.remove_item(item)


func _cleanup_connections() -> void:
	_char_view.item_added.disconnect(_on_item_added_in_char_view)
	_char_view.item_removed.disconnect(_on_item_removed_from_char_view)
	if _merc_view:
		_merc_view.item_added.disconnect(_on_item_added_in_merc_view)
		_merc_view.item_removed.disconnect(_on_item_removed_from_merc_view)
