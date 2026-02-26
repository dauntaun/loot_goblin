extends Node

# ===== Unique =====
var grail_uniques: Dictionary[int, GrailEntry] # by unique_id

var unique_main_categories := ["Weapon", "Armor", "Misc", "Uber"]
var unique_subcategories := ["Axe 1H", "Axe 2H", "Mace 1H", "Mace 2H", "Sword 1H", "Sword 2H", "Dagger", "Throwing", "Spear", "Polearm", "Bow", "Crossbow", "Staff", "Wand", "Scepter", "Claw", "Orb", "Amazon", "Helm", "Circlet", "Armor", "Shield", "Gloves", "Boots", "Belt", "Druid Helm", "Barbarian Helm", "Paladin Shield", "Necromancer Shield", "Arrows", "Bolts", "Amulet", "Ring", "Charm", "Jewel", "Map", "DClone", "Rathma"]

var unique_total_completion: Dictionary
var unique_completion_by_main_category: Dictionary[String, Dictionary]
var unique_completion_by_subcategory: Dictionary[String, Dictionary]

# ===== Set =====
var grail_sets: Dictionary[int, GrailEntry]

var set_main_categories := ["Common", "Uncommon", "Class-Focused"]
var set_subcategories := ["Arctic Gear", "Hsarus' Defense", "Berserker's Arsenal", "Cleglaw's Brace", "Infernal Tools", "Death's Disguise", "Sigon's Complete Steel", "Isenhart's Armory", "Civerb's Vestments", "Cathan's Traps", "Angelic Raiment", "Vidala's Rig", "Arcanna's Tricks", "Iratha's Finery", "Milabrega's Regalia", "Tancred's Battlegear", "Cow King's Leathers", "Sander's Folly", "Hwanin's Majesty", "Orphan's Call", "The Disciple", "Naj's Ancient Vestige", "Sazabi's Grand Tribute", "Heaven's Brethren", "Bul-Kathos' Children", "Aldur's Watchtower", "Griswold's Legacy", "Immortal King", "M'avina's Battle Hymn", "Natalya's Odium", "Tal Rasha's Wrappings", "Trang-Oul's Avatar"]
var common_sets := ["Arctic Gear", "Hsarus' Defense", "Berserker's Arsenal", "Cleglaw's Brace", "Infernal Tools", "Death's Disguise", "Sigon's Complete Steel", "Isenhart's Armory", "Civerb's Vestments", "Cathan's Traps", "Angelic Raiment", "Vidala's Rig", "Arcanna's Tricks", "Iratha's Finery", "Milabrega's Regalia", "Tancred's Battlegear"]
var uncommon_sets := ["Cow King's Leathers", "Sander's Folly", "Hwanin's Majesty", "Orphan's Call", "The Disciple", "Naj's Ancient Vestige", "Sazabi's Grand Tribute", "Heaven's Brethren", "Bul-Kathos' Children"]
var class_focused_sets := ["Aldur's Watchtower", "Griswold's Legacy", "Immortal King", "M'avina's Battle Hymn", "Natalya's Odium", "Tal Rasha's Wrappings", "Trang-Oul's Avatar"]

var set_total_completion: Dictionary
var set_completion_by_main_category: Dictionary[String, Dictionary]
var set_completion_by_subcategory: Dictionary[String, Dictionary]


func _ready() -> void:
	for category: String in unique_subcategories:
		unique_completion_by_subcategory[category] = {"total": 0, "found": 0, "missing": 0, "missing_eth": 0}
	for category: String in unique_main_categories:
		unique_completion_by_main_category[category] = {"total": 0, "found": 0, "missing": 0, "missing_eth": 0}
	unique_total_completion = {"total": 0, "found": 0, "missing": 0, "missing_eth": 0}
	
	for category: String in set_subcategories:
		set_completion_by_subcategory[category] = {"total": 0, "found": 0, "missing": 0, "missing_eth": 0}
	for category: String in set_main_categories:
		set_completion_by_main_category[category] = {"total": 0, "found": 0, "missing": 0, "missing_eth": 0}
	set_total_completion = {"total": 0, "found": 0, "missing": 0, "missing_eth": 0}


func update_grail() -> void:
	for item: D2Item in ItemRegistry.item_register.values():
		if item.rarity == D2Item.ItemRarity.UNIQUE:
			grail_uniques[item.unique_id].found = true
			grail_uniques[item.unique_id].found_eth = grail_uniques[item.unique_id].found_eth or item.is_ethereal
		elif item.rarity == D2Item.ItemRarity.SET:
			grail_sets[item.set_id].found = true
			grail_sets[item.set_id].found_eth = grail_sets[item.set_id].found_eth or item.is_ethereal
	
	for entry: GrailEntry in grail_uniques.values():
		unique_completion_by_subcategory[entry.subcategory].total += 1
		unique_completion_by_main_category[entry.main_category].total += 1
		unique_total_completion.total += 1
		if entry.found:
			unique_completion_by_subcategory[entry.subcategory].found += 1
			unique_completion_by_main_category[entry.main_category].found += 1
			unique_total_completion.found += 1
		else:
			unique_completion_by_subcategory[entry.subcategory].missing += 1
			unique_completion_by_main_category[entry.main_category].missing += 1
			unique_total_completion.missing += 1
		if entry.eth_possible and not entry.found_eth:
			unique_completion_by_subcategory[entry.subcategory].missing_eth += 1
			unique_completion_by_main_category[entry.main_category].missing_eth += 1
			unique_total_completion.missing_eth += 1
	
	for entry: GrailEntry in grail_sets.values():
		set_completion_by_subcategory[entry.subcategory].total += 1
		set_completion_by_main_category[entry.main_category].total += 1
		set_total_completion.total += 1
		if entry.found:
			set_completion_by_subcategory[entry.subcategory].found += 1
			set_completion_by_main_category[entry.main_category].found += 1
			set_total_completion.found += 1
		else:
			set_completion_by_subcategory[entry.subcategory].missing += 1
			set_completion_by_main_category[entry.main_category].missing += 1
			set_total_completion.missing += 1
		if entry.eth_possible and not entry.found_eth:
			set_completion_by_subcategory[entry.subcategory].missing_eth += 1
			set_completion_by_main_category[entry.main_category].missing_eth += 1
			set_total_completion.missing_eth += 1
