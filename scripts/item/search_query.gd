class_name ItemSearchQuery

enum QuickFilter {TYPE, WEAPON, WEAPON_SIZE, WEAPON_TYPE, ARMOR, MISC, CLASS, RARITY, TIER, PROPERTY}

# Quick filter query
var _quickfilter_query := CompiledQuickFilterQuery.new()
# Searchbar query
var _string_query := CompiledStringQuery.new()
# Incremental build
var _previous_string_query: CompiledStringQuery
var _incremental_invalidated := false


func set_quick_filter(quick_filter: QuickFilter, values: Array[int]) -> void:
	_quickfilter_query.compile(quick_filter, values)
	_incremental_invalidated = true


func set_string_query(string_query: String) -> void:
	_string_query = CompiledStringQuery.new(string_query)


func matches(item: D2Item) -> bool:
	if not _quickfilter_query.matches(item):
		return false
		
	if not _string_query.matches(item):
		return false
		
	return true


func can_filter_incrementally() -> bool:
	if _incremental_invalidated:
		return false
	if _previous_string_query:
		if not _string_query.continues(_previous_string_query):
			return false
	return true


func mark_applied() -> void:
	_previous_string_query = _string_query
	_incremental_invalidated = false


class CompiledQuickFilterQuery:
	enum TypeFilter {
		# Weapon 21 types
		AXE, CLUB, MACE, HAMMER, SWORD, DAGGER, THROWING_AXE, THROWING_KNIFE, JAVELIN, AMAZON_JAVELIN, SPEAR, AMAZON_SPEAR, POLEARM, BOW, AMAZON_BOW, CROSSBOW, STAFF, WAND, SCEPTER, CLAW, ORB,
		# Armor 11 types
		HELM, CIRCLET, ARMOR, SHIELD, GLOVES, BOOTS, BELT, DRUID_HELM, BARBARIAN_HELM, PALADIN_SHIELD, NECROMANCER_SHIELD,
		# Misc 9 types
		RING, AMULET, ARROWS, BOLTS, SMALL_CHARM, LARGE_CHARM, GRAND_CHARM, JEWEL, MAP
		}
	enum WeaponSizeFilter {ONE_HANDED, TWO_HANDED}
	enum WeaponTypeFilter {MELEE, MISSILE, THROWING}
	enum RarityFilter {RUNEWORD, NORMAL, MAGIC, RARE, CRAFTED, UNIQUE, SET}
	enum TierFilter {NORMAL, EXCEPTIONAL, ELITE}
	enum ClassFilter {NON_CLASS, AMAZON, ASSASSIN, BARBARIAN, DRUID, PALADIN, SORCERESS, NECROMANCER}
	enum PropertyFilter {ETHEREAL, SOCKETED, CORRUPTED}
	
	var _active_filters: Dictionary[QuickFilter, Array] # Array[int]


	func compile(quick_filter: QuickFilter, values: Array[int]) -> void:
		_active_filters[quick_filter] = values


	func matches(item: D2Item) -> bool:
		for filter: QuickFilter in _active_filters:
			var values: Array[int] = _active_filters[filter]
			if values.is_empty(): # Return true by default if no filters are selected
				continue
			var match_function := _get_match_function(filter)
			var filter_matched: bool
			for value: int in values:
				if match_function.call(item, value):
					filter_matched = true
					break
			if not filter_matched: # Match filters by logical AND
				return false
		return true


	func _get_match_function(filter: QuickFilter) -> Callable:
		match filter:
			QuickFilter.TYPE:
				return _item_matches_type
			QuickFilter.RARITY:
				return _item_matches_rarity
			QuickFilter.TIER:
				return _item_matches_tier
			QuickFilter.PROPERTY:
				return _item_matches_property
			QuickFilter.WEAPON_TYPE:
				return _item_matches_weapon_type
			QuickFilter.WEAPON_SIZE:
				return _item_matches_weapon_size
			QuickFilter.CLASS:
				return _item_matches_class
		return func() -> void: pass


	func _item_matches_type(item: D2Item, type: TypeFilter) -> bool:
			match type:
				# Weapon
				TypeFilter.AXE: return item.item_type == "Axe"
				TypeFilter.CLUB: return item.item_type == "Club"
				TypeFilter.MACE: return item.item_type == "Mace"
				TypeFilter.HAMMER: return item.item_type == "Hammer"
				TypeFilter.SWORD: return item.item_type == "Sword"
				TypeFilter.DAGGER: return item.item_type == "Dagger"
				TypeFilter.THROWING_AXE: return item.item_type == "Throwing Axe"
				TypeFilter.THROWING_KNIFE: return item.item_type == "Throwing Knife"
				TypeFilter.JAVELIN: return item.item_type == "Javelin"
				TypeFilter.SPEAR: return item.item_type == "Spear"
				TypeFilter.POLEARM: return item.item_type == "Polearm"
				TypeFilter.BOW: return item.item_type == "Bow"
				TypeFilter.CROSSBOW: return item.item_type == "Crossbow"
				TypeFilter.STAFF: return item.item_type == "Staff"
				TypeFilter.WAND: return item.item_type == "Wand"
				TypeFilter.SCEPTER: return item.item_type == "Scepter"
				TypeFilter.CLAW: return item.item_type == "Claw"
				TypeFilter.ORB: return item.item_type == "Orb"
				TypeFilter.AMAZON_BOW: return item.item_type == "Amazon Bow"
				TypeFilter.AMAZON_SPEAR: return item.item_type == "Amazon Spear"
				TypeFilter.AMAZON_JAVELIN: return item.item_type == "Amazon Javelin"
				# Armor
				TypeFilter.HELM: return item.item_type == "Helm"
				TypeFilter.CIRCLET: return item.item_type == "Circlet"
				TypeFilter.ARMOR: return item.item_type == "Armor"
				TypeFilter.SHIELD: return item.item_type == "Shield"
				TypeFilter.GLOVES: return item.item_type == "Gloves"
				TypeFilter.BOOTS: return item.item_type == "Boots"
				TypeFilter.BELT: return item.item_type == "Belt"
				TypeFilter.DRUID_HELM: return item.item_type == "Druid Helm"
				TypeFilter.BARBARIAN_HELM: return item.item_type == "Barbarian Helm"
				TypeFilter.PALADIN_SHIELD: return item.item_type == "Paladin Shield"
				TypeFilter.NECROMANCER_SHIELD: return item.item_type == "Necromancer Shield"
				# Misc
				TypeFilter.RING: return item.item_type == "Ring"
				TypeFilter.AMULET: return item.item_type == "Amulet"
				TypeFilter.ARROWS: return item.item_type == "Bow Quiver"
				TypeFilter.BOLTS: return item.item_type == "Crossbow Quiver"
				TypeFilter.SMALL_CHARM: return item.item_type == "Small Charm"
				TypeFilter.LARGE_CHARM: return item.item_type == "Large Charm"
				TypeFilter.GRAND_CHARM: return item.item_type == "Grand Charm"
				TypeFilter.JEWEL: return item.item_type == "Jewel"
				TypeFilter.MAP: return item.item_type in ["Map T1", "Map T2", "Map T3"]
			return false


	func _item_matches_weapon_type(item: D2Item, weapon_type: WeaponTypeFilter) -> bool:
		match weapon_type:
			WeaponTypeFilter.MELEE: return item.is_weapon and not item.item_type in ["Bow", "Crossbow", "Amazon Bow", "Throwing Axe", "Throwing Knife", "Javelin", "Amazon Javelin", "Orb"]
			WeaponTypeFilter.MISSILE: return item.item_type in ["Bow", "Crossbow", "Amazon Bow"]
			WeaponTypeFilter.THROWING: return item.item_type in ["Throwing Axe", "Throwing Knife", "Javelin", "Amazon Javelin"]
		return false


	func _item_matches_weapon_size(item: D2Item, weapon_size: WeaponSizeFilter) -> bool:
		match weapon_size:
			WeaponSizeFilter.ONE_HANDED: return item.weapon_damage.has("onehand") and not item.weapon_damage.has("twohand")
			WeaponSizeFilter.TWO_HANDED: return item.weapon_damage.has("twohand")
		return false


	func _item_matches_class(item: D2Item, d2_class: ClassFilter) -> bool:
		match d2_class:
			ClassFilter.NON_CLASS: return item.item_class == D2Item.ClassSpecific.ANY
			ClassFilter.AMAZON: return item.item_class == D2Item.ClassSpecific.AMA
			ClassFilter.ASSASSIN: return item.item_class == D2Item.ClassSpecific.ASS
			ClassFilter.BARBARIAN: return item.item_class == D2Item.ClassSpecific.BAR
			ClassFilter.DRUID: return item.item_class == D2Item.ClassSpecific.DRU
			ClassFilter.PALADIN: return item.item_class == D2Item.ClassSpecific.PAL
			ClassFilter.SORCERESS: return item.item_class == D2Item.ClassSpecific.SOR
			ClassFilter.NECROMANCER: return item.item_class == D2Item.ClassSpecific.NEC
		return false


	func _item_matches_rarity(item: D2Item, rarity: RarityFilter) -> bool:
		match rarity:
			RarityFilter.NORMAL: return item.rarity in \
			[D2Item.ItemRarity.NORMAL, D2Item.ItemRarity.INFERIOR, D2Item.ItemRarity.SUPERIOR] and not item.has_runeword
			RarityFilter.RUNEWORD: return item.has_runeword
			RarityFilter.MAGIC: return item.rarity == D2Item.ItemRarity.MAGIC
			RarityFilter.RARE: return item.rarity == D2Item.ItemRarity.RARE
			RarityFilter.CRAFTED: return item.rarity == D2Item.ItemRarity.CRAFTED
			RarityFilter.UNIQUE: return item.rarity == D2Item.ItemRarity.UNIQUE
			RarityFilter.SET:    return item.rarity == D2Item.ItemRarity.SET
		return false


	func _item_matches_property(item: D2Item, property: PropertyFilter) -> bool:
		match property:
			PropertyFilter.ETHEREAL: return item.is_ethereal
			PropertyFilter.SOCKETED: return item.is_socketed
			PropertyFilter.CORRUPTED:return item.is_corrupted
		return false


	func _item_matches_tier(item: D2Item, tier: TierFilter) -> bool:
		match tier:
			TierFilter.NORMAL: return item.item_tier == D2Item.ItemTier.NORMAL
			TierFilter.EXCEPTIONAL: return item.item_tier == D2Item.ItemTier.EXCEPTIONAL
			TierFilter.ELITE: return item.item_tier == D2Item.ItemTier.ELITE
		return false


class CompiledStringQuery:
	enum TermKind {
		TEXT,
		TYPE,
		RARITY,
		SOCKETS,
	}

	var _raw_query: String
	var _compiled_terms: Array
	
	func _init(query: String = "") -> void:
		compile(query)
	
	func compile(query: String) -> void:
		_raw_query = query.strip_edges().to_lower()
		_compiled_terms.clear()
		
		if _raw_query.is_empty():
			return

		for raw_term: String in _raw_query.split("&", false):
			var term := raw_term.strip_edges()
			if term.is_empty():
				continue

			var negated := term.begins_with("!")
			if negated:
				term = term.substr(1).strip_edges()
				if term.is_empty():
					continue

			var compiled_term := _compile_single_term(term, negated)
			if compiled_term == null:
				continue
				
			_compiled_terms.append(compiled_term)
	
	func matches(item: D2Item) -> bool:
		for compiled_term: Dictionary in _compiled_terms:
			if not _match_compiled_term(item, compiled_term):
				return false
		return true

	func get_raw_query() -> String:
		return _raw_query

	func _matches_type_filter(item: D2Item, term: String) -> bool:
		var parts: PackedStringArray = term.split(":", false)
		var item_type: String = item.item_type.to_lower()
		var value: String = parts[1].strip_edges()
		return item_type.contains(value)

	func _matches_rarity_filter(item: D2Item, term: String) -> bool:
		var parts: PackedStringArray = term.split(":", false)
		var item_rarity: String = D2Item.ItemRarity.find_key(item.rarity).to_lower()
		if item.has_runeword:
			item_rarity = "runeword"
		elif item.rarity in [D2Item.ItemRarity.INFERIOR, D2Item.ItemRarity.SUPERIOR]:
			item_rarity += " normal"
		var value: String = parts[1].strip_edges()
		return item_rarity.contains(value)

	func _matches_socket_filter(item: D2Item, term: String) -> bool:
		var parts: PackedStringArray = term.split(":", false)
		var socket_count: int = item.total_sockets
		var value: String = parts[1].strip_edges()

		# Range: value = "3-5"
		if value.contains("-"):
			var value_range = value.split("-", false)
			if value_range.size() != 2:
				return true

			if not value_range[0].is_valid_int() or not value_range[1].is_valid_int():
				return false

			var min_sockets := int(value_range[0])
			var max_sockets := int(value_range[1])

			if min_sockets > max_sockets:
				return false

			return socket_count >= min_sockets and socket_count <= max_sockets

		# Exact match: value = "4"
		if value.is_valid_int():
			return socket_count == int(value)

		return false

	func _compile_single_term(term: String, negated: bool) -> Dictionary:
		if term.begins_with("s:") or term.begins_with("sockets:"):
			var term_complete := term.split(":", false).size() > 1
			return { "kind": TermKind.SOCKETS, "value": term, "negated": negated, "complete": term_complete}
		elif term.begins_with("t:") or term.begins_with("type:"):
			var term_complete := term.split(":", false).size() > 1
			return { "kind": TermKind.TYPE, "value": term, "negated": negated, "complete": term_complete}
		elif term.begins_with("r:") or term.begins_with("rarity:"):
			var term_complete := term.split(":", false).size() > 1
			return { "kind": TermKind.RARITY, "value": term, "negated": negated, "complete": term_complete }
		else:
			return { "kind": TermKind.TEXT, "value": term, "negated": negated, "complete": true}

	func _match_compiled_term(item: D2Item, compiled_term: Dictionary) -> bool:
		if not compiled_term["complete"]:
			return true
			
		var result: bool
		match compiled_term.kind:
			TermKind.TEXT:
				result = item.search_cache.contains(compiled_term.value)
			TermKind.TYPE:
				result = _matches_type_filter(item, compiled_term.value)
			TermKind.RARITY:
				result = _matches_rarity_filter(item, compiled_term.value)
			TermKind.SOCKETS:
				result = _matches_socket_filter(item, compiled_term.value)
			
		if compiled_term["negated"]: result = not result
		return result
	
	
	func continues(previous: CompiledStringQuery) -> bool:
		if _compiled_terms.size() != previous._compiled_terms.size():
			return false

		for i: int in _compiled_terms.size():
			var a = _compiled_terms[i]
			var b = previous._compiled_terms[i]

			if a.kind != b.kind:
				return false
			if a.negated != b.negated:
				return false
			if a.complete != b.complete:
				return false
			if not _raw_query.begins_with(previous._raw_query):
				return false

		return true
