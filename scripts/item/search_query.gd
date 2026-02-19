class_name ItemSearchQuery

enum QuickFilter {TYPE, RARITY, TIER, PROPERTY}

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
	enum TypeFilter {WEAPON, ARMOR, RING, AMULET, QUIVER, CHARM, JEWEL, MAP}
	enum RarityFilter {RUNEWORD, NORMAL, MAGIC, RARE, CRAFTED, UNIQUE, SET}
	enum TierFilter {NORMAL, EXCEPTIONAL, ELITE}
	enum PropertyFilter {ETHEREAL, SOCKETED, CORRUPTED}
	
	var _active_types: Array[TypeFilter]
	var _active_rarities: Array[RarityFilter]
	var _active_tiers: Array[TierFilter]
	var _active_properties: Array[PropertyFilter]

	func compile(quick_filter: QuickFilter, values: Array[int]) -> void:
		match quick_filter:
			QuickFilter.TYPE:
				_active_types = values as Array[TypeFilter]
			QuickFilter.RARITY:
				_active_rarities = values as Array[RarityFilter]
			QuickFilter.TIER:
				_active_tiers = values as Array[TierFilter]
			QuickFilter.PROPERTY:
				_active_properties = values as Array[PropertyFilter]


	func matches(item: D2Item) -> bool:
		return _match_properties(item) \
			and _match_types(item) \
			and _match_rarities(item) \
			and _match_tiers(item)

	func _match_types(item: D2Item) -> bool:
		if _active_types.is_empty():
			return true
		for t in _active_types:
			if _item_matches_type(item, t):
				return true
		return false

	func _match_rarities(item: D2Item) -> bool:
		if _active_rarities.is_empty():
			return true
		for r in _active_rarities:
			if _item_matches_rarity(item, r):
				return true
		return false

	func _match_tiers(item: D2Item) -> bool:
			if _active_tiers.is_empty():
				return true
			for t in _active_tiers:
				if _item_matches_tier(item, t):
					return true
			return false

	func _match_properties(item: D2Item) -> bool:
		for p in _active_properties:
			if not _item_matches_property(item, p):
				return false
		return true

	func _item_matches_type(item: D2Item, t: TypeFilter) -> bool:
		match t:
			TypeFilter.WEAPON: return item.is_weapon
			TypeFilter.ARMOR:  return item.is_armor
			TypeFilter.RING:   return item.item_type == "Ring"
			TypeFilter.AMULET:   return item.item_type == "Amulet"
			TypeFilter.QUIVER:   return item.item_type in ["Bow Quiver", "Crossbow Quiver"]
			TypeFilter.CHARM:   return item.item_type in ["Small Charm", "Large Charm", "Grand Charm"]
			TypeFilter.JEWEL:   return item.item_type == "Jewel"
			TypeFilter.MAP:   return item.item_type in ["Map T1", "Map T2", "Map T3"]
			_: return false

	func _item_matches_rarity(item: D2Item, r: RarityFilter) -> bool:
		match r:
			RarityFilter.NORMAL: return item.rarity in \
			[D2Item.ItemRarity.NORMAL, D2Item.ItemRarity.INFERIOR, D2Item.ItemRarity.SUPERIOR] and not item.has_runeword
			RarityFilter.RUNEWORD: return item.has_runeword
			RarityFilter.MAGIC: return item.rarity == D2Item.ItemRarity.MAGIC
			RarityFilter.RARE: return item.rarity == D2Item.ItemRarity.RARE
			RarityFilter.CRAFTED: return item.rarity == D2Item.ItemRarity.CRAFTED
			RarityFilter.UNIQUE: return item.rarity == D2Item.ItemRarity.UNIQUE
			RarityFilter.SET:    return item.rarity == D2Item.ItemRarity.SET
			_: return false

	func _item_matches_property(item: D2Item, p: PropertyFilter) -> bool:
		match p:
			PropertyFilter.ETHEREAL: return item.is_ethereal
			PropertyFilter.SOCKETED: return item.is_socketed
			PropertyFilter.CORRUPTED:return item.is_corrupted
		return true
	
	func _item_matches_tier(item: D2Item, t: TierFilter) -> bool:
		match t:
			TierFilter.NORMAL: return item.item_tier == D2Item.ItemTier.NORMAL
			TierFilter.EXCEPTIONAL: return item.item_tier == D2Item.ItemTier.EXCEPTIONAL
			TierFilter.ELITE: return item.item_tier == D2Item.ItemTier.ELITE

		return true


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
