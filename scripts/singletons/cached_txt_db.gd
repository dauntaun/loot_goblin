class_name CachedTxtDB
extends Resource

@export var all_codes: Dictionary
@export var weapon_codes: Dictionary
@export var armor_codes: Dictionary
@export var misc_codes: Dictionary
@export var magic_prefix: Dictionary
@export var magic_suffix: Dictionary
@export var rare_prefix: Dictionary
@export var rare_suffix: Dictionary
@export var unique_items: Dictionary
@export var set_items: Dictionary
@export var item_types: Dictionary
@export var runewords: Dictionary
@export var runewords_parsed: Dictionary
@export var damage_ranges: Dictionary
@export var item_stat_cost: Dictionary
@export var stat_cost_parsed: Dictionary
@export var item_stat_cost_by_code: Dictionary
@export var localization_table: Dictionary
@export var skill_table: Dictionary
@export var skill_desc: Dictionary
@export var charstat_table: Dictionary
@export var monster_table: Dictionary
@export var monstertype_table: Dictionary
@export var gems: Dictionary
@export var gem_props: Dictionary
@export var properties: Dictionary

# For D2Colors
@export var orange_item_codes: Array[String]
@export var gold_item_codes: Array[String]
@export var purple_item_codes: Array[String]
@export var red_item_codes: Array[String]

# For Grail
@export var grail_uniques: Dictionary[int, GrailEntry]
@export var grail_sets: Dictionary[int, GrailEntry]
