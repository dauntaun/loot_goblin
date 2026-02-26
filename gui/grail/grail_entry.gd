class_name GrailEntry
extends Resource

# Grail
@export var txt_id: int ## unique/set_id
@export var main_category: String
@export var subcategory: String
@export var found: bool
@export var found_eth: bool
# Item
@export var item_rarity: D2Item.ItemRarity
@export var item_name: String
@export var item_base_name: String
@export var item_tier: String
@export var item_type: String
@export var item_tc: String
@export var item_qlvl: int
@export var eth_possible: bool
