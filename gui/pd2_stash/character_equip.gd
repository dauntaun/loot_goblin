class_name CharacterEquipGUI
extends PanelContainer

signal item_selected(item: D2Item)

const ITEM_RECT_SCENE = preload("uid://dmcf3j2822imo")

@export var is_merc: bool = false
# Weapon swap
@onready var swap_1: Button = %Swap1
@onready var swap_2: Button = %Swap2
@onready var swap_11: Button = %Swap11
@onready var swap_22: Button = %Swap22
@onready var left_tab: TabContainer = %LeftTab
@onready var right_tab: TabContainer = %RightTab
# Equip panels
@onready var gloves: PanelContainer = %Gloves
@onready var left_ring: PanelContainer = %LeftRing
@onready var helmet: PanelContainer = %Helmet
@onready var chest: PanelContainer = %Chest
@onready var belt: PanelContainer = %Belt
@onready var amulet: PanelContainer = %Amulet
@onready var right_ring: PanelContainer = %RightRing
@onready var right_arm: PanelContainer = %RightArm
@onready var alt_right_arm: PanelContainer = %AltRightArm
@onready var left_arm: PanelContainer = %LeftArm
@onready var alt_left_arm: PanelContainer = %AltLeftArm
@onready var boots: PanelContainer = %Boots

@onready var equip_map: Dictionary[D2Item.EquipLocation, PanelContainer] = {
	D2Item.EquipLocation.HEAD: helmet,
	D2Item.EquipLocation.TORSO: chest,
	D2Item.EquipLocation.HANDS: gloves,
	D2Item.EquipLocation.FEET: boots,
	D2Item.EquipLocation.WAIST: belt,
	D2Item.EquipLocation.NECK: amulet,
	D2Item.EquipLocation.FINGER_LEFT: left_ring,
	D2Item.EquipLocation.FINGER_RIGHT: right_ring,
	D2Item.EquipLocation.HAND_LEFT: left_arm,
	D2Item.EquipLocation.ALT_HAND_LEFT: alt_left_arm,
	D2Item.EquipLocation.HAND_RIGHT: right_arm,
	D2Item.EquipLocation.ALT_HAND_RIGHT: alt_right_arm,
}

var _initialized := false


func _ready() -> void:
	swap_1.pressed.connect(_swap_weapons.bind(1))
	swap_2.pressed.connect(_swap_weapons.bind(2))
	swap_11.pressed.connect(_swap_weapons.bind(1))
	swap_22.pressed.connect(_swap_weapons.bind(2))
	
	swap_1.button_pressed = true
	swap_11.button_pressed = true
	
	if is_merc:
		left_ring.hide()
		right_ring.hide()
		amulet.hide()
		swap_1.hide()
		swap_2.hide()
		swap_11.hide()
		swap_22.hide()


func init_equipped_items(items: Array[D2Item]) -> void:
	if _initialized:
		_clear_equipped_items()
	if items.size() > 12:
		push_error("Too many equipped items")
		return
	for item: D2Item in items:
		var item_rect: ItemRect = ITEM_RECT_SCENE.instantiate()
		equip_map[item.equipped_id].add_child(item_rect)
		item_rect.init_rect(item)
		item_rect.item_selected.connect(_on_item_selected)
	_initialized = true


func _swap_weapons(weapon_set: int) -> void:
	if weapon_set == 1:
		swap_1.button_pressed = true
		swap_11.button_pressed = true
		left_tab.current_tab = 0
		right_tab.current_tab = 0
	else:
		swap_2.button_pressed = true
		swap_22.button_pressed = true
		left_tab.current_tab = 1
		right_tab.current_tab = 1


func _clear_equipped_items() -> void:
	for equip: D2Item.EquipLocation in equip_map:
		for node: Node in equip_map[equip].get_children():
			node.queue_free()


func _on_item_selected(item: D2Item) -> void:
	item_selected.emit(item)
	
