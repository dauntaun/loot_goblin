class_name ItemParser

const ITEM_SIGNATURE: int = 0x4D4A ## JM

static var item_id_counter: int = 0


static func parse_item_list_at_cursor(cursor: BitCursor, item_count: int, item_data: D2ItemList) -> Array[D2Item]:
	if item_count <= 0:
		return []
	var items: Array[D2Item]
	var data := cursor._data
	for i: int in item_count:
		if not cursor.can_read(16):
			push_error("Cursor out of bounds")
			break
		elif data.decode_u16(cursor._bit_pos>>3) == ITEM_SIGNATURE:
			var item: D2Item = _parse_item_at_cursor(cursor)
			item.length = (cursor._bit_pos>>3) - item.start_byte
			item.item_id = item_id_counter
			ItemRegistry.item_data_register[item_id_counter] = item_data
			ItemRegistry.item_register[item_id_counter] = item
			item_id_counter += 1
			items.append(item)
		else:
			push_error("Invalid item header")
			break
	return items


static func _parse_item_at_cursor(cursor: BitCursor) -> D2Item:
	var item := D2Item.new()
	item.start_byte = cursor._bit_pos >> 3
	
	item.is_identified = cursor.jump_and_read(20, 1) # 21
	item.is_socketed = cursor.jump_and_read(6, 1) # 28
	item.is_ear = cursor.jump_and_read(4, 1) # 33
	item.is_simple = cursor.jump_and_read(4, 1) # 38
	item.is_ethereal = cursor.read_bits(1) # 39 
	item.is_personalized = cursor.jump_and_read(1, 1) # 41
	item.has_runeword = cursor.jump_and_read(1, 1) # 43 
	item.location_id = cursor.jump_and_read(15, 3) as D2Item.ItemLocation # 61
	item.equipped_id = cursor.read_bits(4) as D2Item.EquipLocation # 65
	item.x_coord = cursor.read_bits(4) # 69
	item.y_coord = cursor.read_bits(4) # 73
	item.store_id = cursor.read_bits(3) as D2Item.StoreLocation # 76
	
	# Ear return
	if item.is_ear:
		item.code_string = "ear"
		item.item_type = TxtDB.get_item_type(item.code_string)
		item.is_misc = true
		item.inv_width = 1
		item.inv_height = 1
		item.base_name = TxtDB.get_item_base_name("ear")
		item.item_name = item.base_name
		item.build_search_cache()
		
		cursor.discard_to_byte_boundary()
		return item
	
	# Item code
	var code_string: String = ""
	for i: int in 4:
		var char_code: int = cursor.read_bits(8) # 108 after loop
		if char_code == 32: # space terminates
			break
		code_string += char(char_code)
	item.code_string = code_string
	
	item.item_type = TxtDB.get_item_type(code_string)
	item.item_class = TxtDB.get_item_class(code_string)
	item.item_tier = TxtDB.get_item_tier(code_string)
	item.socketed_item_count = cursor.read_bits(3) # 111
	item.inv_width = TxtDB.get_item_dimensions(code_string).x
	item.inv_height = TxtDB.get_item_dimensions(code_string).y
	item.base_name = TxtDB.get_item_base_name(code_string)
	item.is_misc = TxtDB.item_is_misc(code_string)
	item.is_rune = TxtDB.item_is_rune(code_string)
	item.is_tome = TxtDB.item_is_tome(code_string)
	item.is_stackable = TxtDB.item_is_stackable(code_string)
	
	# Simple return
	if item.is_simple:
		item.item_name = item.base_name
		cursor.discard_to_byte_boundary()
		item.build_search_cache()
		return item
	
	item.is_armor = TxtDB.item_is_armor(code_string)
	if item.is_armor:
		item.is_shield = TxtDB.item_is_shield(code_string)
	item.is_weapon = TxtDB.item_is_weapon(code_string)
	var req_str: int = TxtDB.get_item_required_str(code_string)
	var req_dex: int = TxtDB.get_item_required_dex(code_string)
	if item.is_ethereal:
		req_str = clampi(req_str - 10, 0, req_str)
		req_dex = clampi(req_dex - 10, 0, req_dex)
	item.required_strength = req_str
	item.required_dexterity = req_dex
	item.required_level = TxtDB.get_item_required_level(code_string)
	item.unique_signature = cursor.read_bits(32) # 143
	item.item_level = cursor.read_bits(7) # 150
	item.rarity = cursor.read_bits(4) as D2Item.ItemRarity # 154
	item.has_multiple_pictures = cursor.read_bits(1) # 155
	
	# Conditional fields
	if item.has_multiple_pictures:
		item.picture_id = cursor.read_bits(3)
	item.has_automods = cursor.read_bits(1)
	if item.has_automods:
		item.automagic_id = cursor.read_bits(11)
		
	match item.rarity:
		D2Item.ItemRarity.INFERIOR:
			item.inferior_id = cursor.read_bits(3)
			item.item_name = "Inferior %s" % item.base_name #TODO cracked/etc
		D2Item.ItemRarity.NORMAL:
			item.item_name = item.base_name
		D2Item.ItemRarity.SUPERIOR:
			item.superior_id = cursor.read_bits(3)
			item.item_name = "Superior %s" % item.base_name
		D2Item.ItemRarity.MAGIC:
			item.magic_prefix_id = cursor.read_bits(11)
			item.magic_suffix_id = cursor.read_bits(11)
			item.item_name = TxtDB.get_item_magic_name(code_string, item.magic_prefix_id, item.magic_suffix_id)
			var req_level_magic := TxtDB.get_item_required_level_from_affixes([item.magic_prefix_id], [item.magic_suffix_id])
			item.required_level = maxi(item.required_level, req_level_magic)
		D2Item.ItemRarity.SET:
			item.set_id = cursor.read_bits(12)
			item.item_name = TxtDB.get_item_set_name(item.set_id)
			var req_level_set: int = TxtDB.get_item_required_level_set(item.set_id)
			item.required_level = maxi(item.required_level, req_level_set)
		D2Item.ItemRarity.UNIQUE:
			item.unique_id = cursor.read_bits(12)
			item.item_name = TxtDB.get_item_unique_name(item.unique_id)
			var req_level_unique: int = TxtDB.get_item_required_level_unique(item.unique_id)
			item.required_level = maxi(item.required_level, req_level_unique)
		D2Item.ItemRarity.RARE, D2Item.ItemRarity.CRAFTED:
			item.first_rare_name_id = cursor.read_bits(8)
			item.second_rare_name_id = cursor.read_bits(8)
			item.item_name = TxtDB.get_item_rare_name(item.first_rare_name_id, item.second_rare_name_id)
	
	if item.rarity == D2Item.ItemRarity.RARE or item.rarity == D2Item.ItemRarity.CRAFTED:
		for i: int in 6:
			var has_affix: bool = cursor.read_bits(1)
			if not has_affix:
				continue
			var affix_id: int = cursor.read_bits(11)
			# Even indices = prefix, odd indices = suffix
			if (i & 1) == 0:
				item.rare_prefix_ids.append(affix_id)
				item.rare_prefixes.append(TxtDB.get_magic_prefix_name(affix_id))
				item.rare_prefix_amount += 1
			else:
				item.rare_suffix_ids.append(affix_id)
				item.rare_suffixes.append(TxtDB.get_magic_suffix_name(affix_id))
				item.rare_suffix_amount += 1
		var req_level_magic := TxtDB.get_item_required_level_from_affixes(item.rare_prefix_ids, item.rare_suffix_ids)
		item.required_level = maxi(item.required_level, req_level_magic)
	
	if item.has_runeword:
		item.runeword_id = cursor.read_bits(12)
		cursor.discard_bits(4)
	
	if item.is_personalized:
		while true:
			var char_code: int = cursor.read_bits(7)
			if char_code == 0:
				break
			item.personalized_name += char(char_code)
	
	if item.is_tome:
		cursor.discard_bits(5)
	cursor.discard_bits(1)
	
	if item.is_armor:
		item.base_defense = cursor.read_bits(11) - 10
		item.defense = item.base_defense
	if item.is_armor or item.is_weapon:
		item.max_durability = cursor.read_bits(8)
		if item.max_durability > 0:
			item.current_durability = cursor.read_bits(8)
			cursor.discard_bits(1)
		
	if item.is_stackable:
		item.quantity = cursor.read_bits(9)
	if item.is_socketed:
		item.total_sockets = cursor.read_bits(4)
	if item.rarity == D2Item.ItemRarity.SET:
		item.set_prop_bits = cursor.read_bits(5)
	
	# Property lists
	_read_item_property_list(cursor, item.magic_properties)
	# Set properties
	if item.rarity == D2Item.ItemRarity.SET:
		for i: int in 5:
			if (item.set_prop_bits >> i) & 1:
				var bonus_props: Array[Dictionary]
				_read_item_property_list(cursor, bonus_props)
				item.set_properties.append_array(bonus_props)
	
	# Runeword properties
	if item.has_runeword:
		_read_item_property_list(cursor, item.runeword_properties)
	
	# Padding to next byte
	cursor.discard_to_byte_boundary()

	# Internal items
	var socketed_items: Array[D2Item]
	for i: int in item.socketed_item_count:
		var socketed_item: D2Item = _parse_item_at_cursor(cursor)
		socketed_items.append(socketed_item)
	item.socketed_items = socketed_items
	
	#=======================================
	#          END OF BIT PARSING          #
	#=======================================
	
	var property_lists: Array[Array] = [item.magic_properties]
	
	# Runeword name
	if item.has_runeword:
		var rune_codes: Array[String]
		for rune_item: D2Item in socketed_items:
			rune_codes.append(rune_item.code_string)
		item.item_name = TxtDB.get_item_runeword_name(rune_codes)
		property_lists.append(item.runeword_properties)
	
	# Merge and format properties
	for socketed_item: D2Item in item.socketed_items:
		if socketed_item.is_simple:
			var gem_props: Dictionary = TxtDB.get_gem_properties(socketed_item.code_string)
			if item.is_weapon:
				property_lists.append(gem_props.weapon)
			elif item.is_shield:
				property_lists.append(gem_props.shield)
			else:
				property_lists.append(gem_props.armor)
		else:
			property_lists.append(socketed_item.magic_properties)
	
	if property_lists.size() > 1:
		item.all_properties = _combine_property_lists(property_lists)
	else:
		item.all_properties = item.magic_properties
	item.all_properties_formatted = ItemPropertyFormatter.format_properties(item.all_properties)
	
	item.build_search_cache()
	item.is_corrupted = TxtDB.item_is_corrupted(item.magic_properties)
	if item.is_weapon:
		item.base_weapon_damage = TxtDB.get_weapon_damage_range(code_string, item.is_ethereal)
		item.weapon_damage = item.base_weapon_damage.duplicate_deep()
	
	if item.is_armor:
		for property: Dictionary in item.all_properties:
			if property.stat_id == 16: # Enhanced defense
				var ed_mult: float = (1 + property.params[0] / 100.0)
				item.defense = floor(item.base_defense * (1 + property.params[0] / 100.0))
			if property.stat_id == 31: # Flat defense
				item.defense += property.params[0]
			if property.stat_id == 214: # Flat defense per level
				var bonus_defense := floori((float(property.params[0]) / 8) * GlobalSettings.character_level)
				item.defense += bonus_defense
			if property.stat_id == 215: # Enhanced defense per level
				push_error("Enhanced defense per level not implemented")
			if property.stat_id == 91: # -Requirements
				if item.required_dexterity > 0:
					item.required_dexterity = ceili(item.required_dexterity * (1 + property.params[0] / 100.0))
				if item.required_strength > 0:
					item.required_strength = ceili(item.required_strength * (1 + property.params[0] / 100.0))
	elif item.is_weapon:
		for property: Dictionary in item.all_properties:
			if property.stat_id == 18: # Enhanced damage
				for dam_type: String in item.weapon_damage:
					item.weapon_damage[dam_type]["min"] += floori(item.base_weapon_damage[dam_type]["min"] * (property.params[0] / 100.0))
					item.weapon_damage[dam_type]["max"] += floori(item.base_weapon_damage[dam_type]["max"] * (property.params[0] / 100.0))
			if property.stat_id == 219: # Enhanced max damage per level
				var bonus_max_ed := floori((float(property.params[0]) / 8) * GlobalSettings.character_level)
				for dam_type: String in item.weapon_damage:
					item.weapon_damage[dam_type]["max"] += floori(item.base_weapon_damage[dam_type]["max"] * (bonus_max_ed / 100.0))
			if property.stat_id == 21: # Flat min damage
				for dam_type: String in item.weapon_damage:
					item.weapon_damage[dam_type]["min"] += property.params[0]
			if property.stat_id == 22: # Flat max damage
				for dam_type: String in item.weapon_damage:
					item.weapon_damage[dam_type]["max"] += property.params[0]
			if property.stat_id == 218: # Max damage per level
				var bonus_damage := floori((float(property.params[0]) / 8) * GlobalSettings.character_level)
				for dam_type: String in item.weapon_damage:
					item.weapon_damage[dam_type]["max"] += bonus_damage
			if property.stat_id == 91: # -Requirements
				if item.required_dexterity > 0:
					item.required_dexterity = ceili(item.required_dexterity * (1 + property.params[0] / 100.0))
				if item.required_strength > 0:
					item.required_strength = ceili(item.required_strength * (1 + property.params[0] / 100.0))
	
	return item


static func _read_item_property_list(cursor: BitCursor, target_array: Array[Dictionary]) -> void:
	while true:
		var id: int = cursor.read_bits(9)
		if id == 0x1FF:
			return

		var stat: Dictionary = TxtDB.get_item_stat_cost(id)

		var prop := {
			"stat_id": id,
			"params": []
		}

		if stat.encode == 2:
			prop.params.append(cursor.read_bits(6) - stat.save_add)
			prop.params.append(cursor.read_bits(10) - stat.save_add)
			prop.params.append(cursor.read_bits(stat.save_bits) - stat.save_add)

		elif stat.encode == 3:
			prop.params.append(cursor.read_bits(6) - stat.save_add)
			prop.params.append(cursor.read_bits(10) - stat.save_add)
			prop.params.append(cursor.read_bits(8) - stat.save_add)
			prop.params.append(cursor.read_bits(8) - stat.save_add)

		elif stat.save_param_bits > 0:
			prop.params.append(cursor.read_bits(stat.save_param_bits) - stat.save_add)
			prop.params.append(cursor.read_bits(stat.save_bits) - stat.save_add)

		else:
			prop.params.append(cursor.read_bits(stat.save_bits) - stat.save_add)

		target_array.append(prop)
		
		# Chained stats
		var next_id: int = stat.next_in_chain
		while next_id != 0:
			var next_stat: Dictionary = TxtDB.get_item_stat_cost(next_id)
			var next_param: int = cursor.read_bits(next_stat.save_bits) - next_stat.save_add 
			var next_prop := {"stat_id": next_id, "params": [next_param]}
			target_array.append(next_prop)
			next_id = next_stat.next_in_chain


static func _combine_property_lists(property_lists: Array[Array]) -> Array[Dictionary]:
	var all_properties: Array[Dictionary]
	var merge_index: Dictionary

	var i := 0
	while i < property_lists.size():
		var props = property_lists[i]
		var j := 0
		while j < props.size():
			var prop = props[j]

			if prop.has("stat_id") and prop.has("params") and prop.params.size() == 1:
				var stat_id: int = prop.stat_id
				if merge_index.has(stat_id):
					all_properties[merge_index[stat_id]].params[0] += prop.params[0]
				else:
					var new_prop = prop.duplicate(true)
					merge_index[stat_id] = all_properties.size()
					all_properties.append(new_prop)
			else:
				all_properties.append(prop.duplicate(true))
			j += 1
		i += 1

	return all_properties
