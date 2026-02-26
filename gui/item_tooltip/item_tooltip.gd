class_name ItemTooltip
extends PanelContainer

@onready var label: RichTextLabel = $Label


func set_compact_tooltip(enabled: bool) -> void:
	if enabled:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	else:
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


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
	
	#label.add_text("ilvl: %d" % [item.item_level])
	#label.newline()
	
	# Properties
	_parse_properties(item.all_properties_formatted)
	if item.is_ethereal:
		label.add_text("Ethereal (Cannot Be Repaired)")
	if item.is_ethereal and item.total_sockets > 0:
		label.add_text(", ")
	if item.total_sockets > 0:
		label.add_text("Socketed (%d)" % [item.total_sockets])
		label.newline()


func _parse_properties(properties: Array) -> void:
	label.push_color(D2Colors.COLOR_MAGIC)
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
			label.newline()
	
