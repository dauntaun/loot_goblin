class_name ItemTooltip
extends PanelContainer

const PROPERTY_REGEX_PATTERN_BY_CORRUPT_VALUE := {
	2: "Enhanced Damage",
	3: "to Attack Rating",
	4: "Life after each Hit",
	5: "Attack Rating against Demons|Damage to Demons",
	6: "Requirements -",
	7: "Better Chance of Getting Magic Items",
	8: "Life after each Kill",
	9: "Mana after each Kill",
	10: r"\+\d+ to Mana",
	11: "Faster Hit Recovery",
	12: "Enemy Fire Resistance",
	13: "Enemy Lightning Resistance",
	14: "Enemy Cold Resistance",
	15: "Enemy Poison Resistance",
	16: "Faster Cast Rate",
	17: "Enhanced Damage|Life stolen per hit",
	18: "to Attack Rating",
	19: "Deadly Strike",
	20: "Increased Attack Speed",
	21: "Crushing Blow",
	22: "Increased Attack Speed|Enhanced Damage",
	23: "Increased Attack Speed|Crushing Blow",
	24: "Ignore Target's Defense|Enhanced Damage",
	25: "Deadly Strike|Enhanced Damage",
	26: "to Attack Rating|Enhanced Damage",
	27: "to All Skills",
	28: "Faster Cast Rate|Fire Skill Damage",
	29: "Faster Cast Rate|Cold Skill Damage",
	30: "Faster Cast Rate|Lightning Skill Damage",
	31: "Faster Cast Rate|Poison Skill Damage",
	32: "Socketed",
	33: "Enhanced Defense",
	34: "Replenish Life|Drain Life",
	35: "Faster Hit Recovery",
	36: r"Fire Resist \+\d+%",
	37: r"Cold Resist \+\d+%",
	38: r"Lightning Resist \+\d+%",
	39: r"Poison Resist \+\d+%",
	40: "Regenerate Mana",
	41: "Attacker Takes Damage of",
	42: "Faster Cast Rate",
	43: "Increase Maximum Life",
	44: "Faster Run/Walk",
	45: "Cannot Be Frozen",
	46: r"Physical Damage Taken Reduced by \d+",
	47: r"Magic Damage Taken Reduced by \d+",
	48: "Indestructible|Enhanced Defense",
	49: "Reduced Curse Duration",
	50: "to All Skills",
	51: r"All Resistances|Fire Resist \+\d+%|Cold Resist \+\d+%|Lightning Resist \+\d+%|Poison Resist \+\d+%",
	52: r"Physical Damage Taken Reduced by \d+%",
	53: r"Maximum Fire Resist|Fire Resist \+\d+%",
	54: r"Maximum Cold Resist|Cold Resist \+\d+%",
	55: r"Maximum Lightning Resist|Lightning Resist \+\d+%",
	56: r"Maximum Poison Resist|Poison Resist \+\d+%",
	57: "Life stolen per hit",
	58: "Mana stolen per hit",
	59: "to Attack Rating|to Light Radius",
	60: "Extra Gold from Monsters",
	61: r"\+\d+ to Life",
	62: "Curse Resistance",
	63: "Chance to Pierce",
	64: "Faster Block Rate",
	65: r"all Attributes|\+\d+ to Strength|\+\d+ to Dexterity|\+\d+ to Vitality|\+\d+ to Energy",
	66: r"-\d+% Target Defense",
	67: "Increased Chance of Blocking",
	68: r"\+\d+ to Strength",
	69: r"\+\d+ to Dexterity",
	70: r"\+\d+ to Vitality",
	71: r"\+\d+ to Energy",
	72: r"to Maximum \w+ Resist",
	73: "Faster Block Rate|Increased Chance of Blocking",
	74: r"\+\d+ to Minimum Damage",
	75: r"\+\d+ to Maximum Damage",
	76: "Ignore Target's Defense",
	77: "Damage to Undead|Attack Rating against Undead",
	78: "Deadly Strike|Density|Experience",
	91: "to Monster Defense Per Hit"
}

@export var compact_tooltip: bool = false
@onready var label: RichTextLabel = $Label


func _ready() -> void:
	set_compact_tooltip(compact_tooltip)


func set_compact_tooltip(enabled: bool) -> void:
	compact_tooltip = enabled
	if enabled:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		label.autowrap_mode = TextServer.AUTOWRAP_OFF


func update_tooltip(item: D2Item) -> void:
	label.clear()
	if not item:
		return
	# Name
	label.push_color(D2Colors.get_item_color(item))
	label.add_text(item.item_name)
	label.newline()
	
	# Base name
	if item.rarity in [D2Item.ItemRarity.RARE, D2Item.ItemRarity.CRAFTED, D2Item.ItemRarity.SET, D2Item.ItemRarity.UNIQUE] or item.has_runeword:
		if item.has_runeword:
			label.pop()
			label.push_color(D2Colors.COLOR_GRAY)
		label.add_text(item.base_name)
		label.newline()
	label.pop()
	
	# Socketed runes
	var runes_string: String = item.get_runes_string()
	if runes_string != "":
		label.push_color(D2Colors.COLOR_UNIQUE)
		label.add_text(runes_string)
		label.newline()
		label.pop()
	
	# Description
	if item.is_armor:
		label.add_text("Defense: ")
		if item.defense > item.base_defense:
			label.push_color(D2Colors.COLOR_MAGIC)
			label.add_text(str(item.defense))
			label.pop()
		else:
			label.add_text(str(item.defense))
		label.newline()
	if item.is_weapon:
		if item.weapon_damage.has("throw"):
			label.add_text("Throw Damage: ")
			if item.weapon_damage["throw"]["max"] > item.base_weapon_damage["throw"]["max"]:
				label.push_color(D2Colors.COLOR_MAGIC)
				label.add_text("%d to %d" % [item.weapon_damage["throw"]["min"], item.weapon_damage["throw"]["max"]])
				label.pop()
			else:
				label.add_text("%d to %d" % [item.weapon_damage["throw"]["min"], item.weapon_damage["throw"]["max"]])
			label.newline()
		if item.weapon_damage.has("onehand"):
			label.add_text("One-Hand Damage: ")
			if item.weapon_damage["onehand"]["max"] > item.base_weapon_damage["onehand"]["max"]:
				label.push_color(D2Colors.COLOR_MAGIC)
				label.add_text("%d to %d" % [item.weapon_damage["onehand"]["min"], item.weapon_damage["onehand"]["max"]])
				label.pop()
			else:
				label.add_text("%d to %d" % [item.weapon_damage["onehand"]["min"], item.weapon_damage["onehand"]["max"]])
			label.newline()
		if item.weapon_damage.has("twohand"):
			label.add_text("Two-Hand Damage: ")
			if item.weapon_damage["twohand"]["max"] > item.base_weapon_damage["twohand"]["max"]:
				label.push_color(D2Colors.COLOR_MAGIC)
				label.add_text("%d to %d" % [item.weapon_damage["twohand"]["min"], item.weapon_damage["twohand"]["max"]])
				label.pop()
			else:
				label.add_text("%d to %d" % [item.weapon_damage["twohand"]["min"], item.weapon_damage["twohand"]["max"]])
			label.newline()
	# Quantity
	if item.is_stackable and item.is_misc and not item.item_type in ["Bow Quiver", "Crossbow Quiver"]:
		label.add_text("Quantity: %d" % item.quantity)
		label.newline()
	# Requirements
	if item.max_durability > 0:
		label.add_text("Durability: %d of %d" % [item.current_durability, item.max_durability])
		label.newline()
	match item.item_class:
		D2Item.ClassSpecific.AMA:
			label.add_text("(Amazon Only)")
			label.newline()
		D2Item.ClassSpecific.SOR:
			label.add_text("(Sorceress Only)")
			label.newline()
		D2Item.ClassSpecific.NEC:
			label.add_text("(Necromancer Only)")
			label.newline()
		D2Item.ClassSpecific.PAL:
			label.add_text("(Paladin Only)")
			label.newline()
		D2Item.ClassSpecific.BAR:
			label.add_text("(Barbarian Only)")
			label.newline()
		D2Item.ClassSpecific.DRU:
			label.add_text("(Druid Only)")
			label.newline()
		D2Item.ClassSpecific.ASS:
			label.add_text("(Assassin Only)")
			label.newline()
	if item.required_dexterity > 0:
		label.add_text("Required Dexterity: %d" % [item.required_dexterity])
		label.newline()
	if item.required_strength > 0:
		label.add_text("Required Strength: %d" % [item.required_strength])
		label.newline()
	if item.required_level > 0:
		label.add_text("Required Level: %d" % [item.required_level])
		label.newline()
	
	if GlobalSettings.show_ilvl_in_tooltips:
		label.add_text("ilvl: %d" % [item.item_level])
		label.newline()
	
	# Properties
	var corrupted_property_search_pattern := ""
	if item.is_corrupted:
		for prop: Dictionary in item.all_properties:
			if prop.stat_id == TxtDB.CORRUPTED_STAT_ID:
				corrupted_property_search_pattern = PROPERTY_REGEX_PATTERN_BY_CORRUPT_VALUE.get(prop.params[1], "")
	_parse_properties(item.all_properties_formatted, corrupted_property_search_pattern)
	if item.is_ethereal:
		label.add_text("Ethereal (Cannot Be Repaired)")
	if item.is_ethereal and item.total_sockets > 0:
		label.add_text(", ")
	if item.total_sockets > 0:
		label.add_text("Socketed (%d)" % [item.total_sockets])
		if item.is_corrupted and corrupted_property_search_pattern == "Socketed":
			label.push_color(D2Colors.COLOR_CORRUPTED)
			label.add_text("*")
			label.pop()
		label.newline()


func _parse_properties(properties: Array, corrupted_search_pattern := "") -> void:
	label.push_color(D2Colors.COLOR_MAGIC)
	var regex := RegEx.create_from_string(corrupted_search_pattern)
	if corrupted_search_pattern != "":
		pass
	for property: String in properties:
		if property.contains("Corrupted"):
			label.push_color(D2Colors.COLOR_CORRUPTED)
			label.add_text("Corrupted")
			label.pop()
			label.newline()
		elif property.contains("\\grey"):
			var cleaned = property.replace("\\grey;", "").replace(":\\blue;", "")
			label.pop()
			label.add_text(cleaned)
			label.push_color(D2Colors.COLOR_MAGIC)
			label.newline()
		else:
			label.add_text(property)
			if corrupted_search_pattern != "" and regex.search(property):
				label.push_color(D2Colors.COLOR_CORRUPTED)
				label.add_text("*")
				label.pop()
			label.newline()
	
