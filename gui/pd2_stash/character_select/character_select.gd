class_name CharacterSelectGUI
extends Control

const BUTTON_SCENE = preload("uid://tgixuggfwchr")
var _characters: Array[D2CharacterSaveFile]
var _current_character: D2CharacterSaveFile

@onready var character_select: GridContainer = %CharacterSelect
@onready var char_inventory: StashPageGUI = %CharInventory
@onready var cube_inventory: StashPageGUI = %CubeInventory
@onready var char_equip: CharacterEquipGUI = %Character
@onready var merc_equip: CharacterEquipGUI = %Mercenary
@onready var pd2_stash: PD2StashGUI = %PD2Stash


func _ready() -> void:
	for node: Node in character_select.get_children():
		node.queue_free()
	char_inventory.item_selected.connect(_on_item_selected)
	cube_inventory.item_selected.connect(_on_item_selected)
	char_equip.item_selected.connect(_on_item_selected)
	merc_equip.item_selected.connect(_on_item_selected)


func init_characters(characters: Array[D2CharacterSaveFile]) -> void:
	_characters = characters
	for node: Node in character_select.get_children():
		node.free()
	
	var base_button: CharacterSelectButton = BUTTON_SCENE.instantiate()
	for character: D2CharacterSaveFile in characters:
		var button := base_button.duplicate()
		character_select.add_child(button)
		button.init_button(character)
		button.pressed.connect(_init_character_inventory.bind(character))
	base_button.queue_free()
	
	var first_button := character_select.get_child(0) as CharacterSelectButton
	if first_button:
		first_button.button_pressed = true
		_init_character_inventory(characters[0])
	
	
func _init_character_inventory(character: D2CharacterSaveFile) -> void:
	if _current_character == character:
		return
	character.read_item_lists()
	var character_item_list := character.item_list.get_itemlist()
	var personal_stash_items := character_item_list.get_stashed_items()
	var equipped_items := character_item_list.get_equipped_items()
	var inventory_items := character_item_list.get_inventory_items()
	var cube_items := character_item_list.get_cube_items()
	pd2_stash.init_personal_page(personal_stash_items)
	char_equip.init_equipped_items(equipped_items)
	char_inventory.init_page(inventory_items)
	cube_inventory.init_page(cube_items)
	
	var merc_items := character.merc_item_list.get_itemlist().get_equipped_items()
	merc_equip.init_equipped_items(merc_items)
	
	_current_character = character


func _on_item_selected(_item: D2Item) -> void:
	pass


func restore_last_selection() -> void:
	pd2_stash.restore_last_selection()
