class_name ItemSearchQuery

enum QuickFilter {TYPE, WEAPON, WEAPON_SIZE, WEAPON_TYPE, CHEST, MISC, CLASS, RARITY, TIER, PROPERTY, SOCKET, ETHEREAL, CORRUPT}

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


func reset_quick_filters() -> void:
	_quickfilter_query = CompiledQuickFilterQuery.new()
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
		HELM, CIRCLET, CHEST, SHIELD, GLOVES, BOOTS, BELT, DRUID_HELM, BARBARIAN_HELM, PALADIN_SHIELD, NECROMANCER_SHIELD,
		# Misc 9 types
		RING, AMULET, ARROWS, BOLTS, SMALL_CHARM, LARGE_CHARM, GRAND_CHARM, JEWEL, MAP
		}
	enum WeaponSizeFilter {ONE_HANDED, TWO_HANDED}
	enum WeaponTypeFilter {MELEE, MISSILE, THROWING}
	enum RarityFilter {RUNEWORD, NORMAL, MAGIC, RARE, CRAFTED, UNIQUE, SET}
	enum TierFilter {NORMAL, EXCEPTIONAL, ELITE}
	enum ClassFilter {NON_CLASS, AMAZON, ASSASSIN, BARBARIAN, DRUID, PALADIN, SORCERESS, NECROMANCER}
	enum PropertyFilter {ETHEREAL, CORRUPTED}
	enum SocketFilter {NONE, ONE, TWO, THREE, FOUR, FIVE, SIX}
	enum EtherealFilter {YES, NO}
	enum CorruptedFilter {YES, NO}
	
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
			QuickFilter.SOCKET:
				return _item_matches_socket
			QuickFilter.ETHEREAL:
				return _item_matches_ethereal
			QuickFilter.CORRUPT:
				return _item_matches_corrupted
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
				TypeFilter.CHEST: return item.item_type == "Chest"
				TypeFilter.SHIELD: return item.item_type == "Shield"
				TypeFilter.GLOVES: return item.item_type == "Gloves"
				TypeFilter.BOOTS: return item.item_type == "Boots"
				TypeFilter.BELT: return item.item_type == "Belt"
				TypeFilter.DRUID_HELM: return item.item_type == "Druid Helm"
				TypeFilter.BARBARIAN_HELM: return item.item_type == "Barbarian Helm"
				TypeFilter.PALADIN_SHIELD: return item.item_type == "Paladin Shield"
				TypeFilter.NECROMANCER_SHIELD: return item.item_type == "Necromancer Shield"
				# Misc
				TypeFilter.RING: return item.base_name == "Ring"
				TypeFilter.AMULET: return item.base_name == "Amulet"
				TypeFilter.ARROWS: return item.item_type == "Arrows"
				TypeFilter.BOLTS: return item.item_type == "Bolts"
				TypeFilter.SMALL_CHARM: return item.base_name == "Small Charm"
				TypeFilter.LARGE_CHARM: return item.base_name == "Large Charm"
				TypeFilter.GRAND_CHARM: return item.base_name == "Grand Charm"
				TypeFilter.JEWEL: return item.item_type == "Jewel"
				TypeFilter.MAP: return item.item_type in ["Map T1", "Map T2", "Map T3", "Map T4", "Map T5"]
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
			PropertyFilter.CORRUPTED:return item.is_corrupted
		return false


	func _item_matches_tier(item: D2Item, tier: TierFilter) -> bool:
		match tier:
			TierFilter.NORMAL: return item.item_tier == D2Item.ItemTier.NORMAL
			TierFilter.EXCEPTIONAL: return item.item_tier == D2Item.ItemTier.EXCEPTIONAL
			TierFilter.ELITE: return item.item_tier == D2Item.ItemTier.ELITE
		return false


	func _item_matches_socket(item: D2Item, sockets: SocketFilter) -> bool:
		match sockets:
			SocketFilter.NONE: return item.total_sockets == 0
			SocketFilter.ONE: return item.total_sockets == 1
			SocketFilter.TWO: return item.total_sockets == 2
			SocketFilter.THREE: return item.total_sockets == 3
			SocketFilter.FOUR: return item.total_sockets == 4
			SocketFilter.FIVE: return item.total_sockets == 5
			SocketFilter.SIX: return item.total_sockets == 6
		return false


	func _item_matches_ethereal(item: D2Item, ethereal: EtherealFilter) -> bool:
		match ethereal:
			EtherealFilter.YES: return item.is_ethereal
			EtherealFilter.NO: return not item.is_ethereal
		return false
	
	
	func _item_matches_corrupted(item: D2Item, corrupt: CorruptedFilter) -> bool:
		match corrupt:
			CorruptedFilter.YES: return item.is_corrupted
			CorruptedFilter.NO: return not item.is_corrupted
		return false


class CompiledStringQuery:
	enum TermKind {
		TEXT,
		TYPE,
		BASE,
		RARITY,
		TIER,
		NUMERIC,
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
	
	func _matches_base_filter(item: D2Item, term: String) -> bool:
		var parts: PackedStringArray = term.split(":", false)
		var item_base: String = item.base_name.to_lower()
		var value: String = parts[1].strip_edges()
		return item_base.contains(value)

	func _matches_rarity_filter(item: D2Item, term: String) -> bool:
		var parts: PackedStringArray = term.split(":", false)
		var item_rarity: String = D2Item.ItemRarity.find_key(item.rarity).to_lower()
		if item.has_runeword:
			item_rarity = "runeword"
		elif item.rarity in [D2Item.ItemRarity.INFERIOR, D2Item.ItemRarity.SUPERIOR]:
			item_rarity += " normal"
		var value: String = parts[1].strip_edges()
		return item_rarity.contains(value)
	
	func _matches_tier_filter(item: D2Item, term: String) -> bool:
		var parts: PackedStringArray = term.split(":", false)
		var item_tier: String = D2Item.ItemTier.find_key(item.item_tier).to_lower()
		var value: String = parts[1].strip_edges()
		return item_tier.contains(value)

	func _matches_numeric_filter(item: D2Item, numeric_expression: NumericExpression) -> bool:
		match numeric_expression.key:
			"reqlvl":
				return NumericExpression.matches(numeric_expression, item.required_level)
			"reqdex":
				return NumericExpression.matches(numeric_expression, item.required_dexterity)
			"reqstr":
				return NumericExpression.matches(numeric_expression, item.required_strength)
			"ilvl":
				return NumericExpression.matches(numeric_expression, item.item_level)
			"sock":
				return NumericExpression.matches(numeric_expression, item.total_sockets)
			"def":
				return NumericExpression.matches(numeric_expression, item.defense)
			"dmg":
				return NumericExpression.matches(numeric_expression, item.average_damage)
			"res":
				return NumericExpression.matches(numeric_expression, item.total_res)
			"fres":
				return _matches_property(item, numeric_expression, 39)
			"lres":
				return _matches_property(item, numeric_expression, 41)
			"cres":
				return _matches_property(item, numeric_expression, 43)
			"pres":
				return _matches_property(item, numeric_expression, 45)
			"ares":
				return _matches_property(item, numeric_expression, 39) and \
				_matches_property(item, numeric_expression, 41) and \
				_matches_property(item, numeric_expression, 43) and \
				_matches_property(item, numeric_expression, 45)
			"maxfres":
				return _matches_property(item, numeric_expression, 40)
			"maxlres":
				return _matches_property(item, numeric_expression, 42)
			"maxcres":
				return _matches_property(item, numeric_expression, 44)
			"maxpres":
				return _matches_property(item, numeric_expression, 46)
			"maxres":
				return _matches_property(item, numeric_expression, 40) and \
				_matches_property(item, numeric_expression, 42) and \
				_matches_property(item, numeric_expression, 44) and \
				_matches_property(item, numeric_expression, 46)
			"fabs":
				return _matches_property(item, numeric_expression, 142)
			"flatfabs":
				return _matches_property(item, numeric_expression, 143)
			"labs":
				return _matches_property(item, numeric_expression, 144)
			"flatlabs":
				return _matches_property(item, numeric_expression, 145)
			"cabs":
				return _matches_property(item, numeric_expression, 149)
			"flatcabs":
				return _matches_property(item, numeric_expression, 150)
			"min":
				return _matches_property(item, numeric_expression, 21)
			"max":
				return _matches_property(item, numeric_expression, 22)
			"dam":
				return _matches_property(item, numeric_expression, 111)
			"fmin":
				return _matches_property(item, numeric_expression, 48)
			"fmax":
				return _matches_property(item, numeric_expression, 49)
			"lmin":
				return _matches_property(item, numeric_expression, 50)
			"lmax":
				return _matches_property(item, numeric_expression, 50)
			"mmin":
				return _matches_property(item, numeric_expression, 52)
			"mmax":
				return _matches_property(item, numeric_expression, 52)
			"cmin":
				return _matches_property(item, numeric_expression, 54)
			"cmax":
				return _matches_property(item, numeric_expression, 55)
			"pmin":
				return _matches_property(item, numeric_expression, 57)
			"pmax":
				return _matches_property(item, numeric_expression, 57)
			"fpierce":
				return _matches_property(item, numeric_expression, 333)
			"lpierce":
				return _matches_property(item, numeric_expression, 334)
			"cpierce":
				return _matches_property(item, numeric_expression, 335)
			"ppierce":
				return _matches_property(item, numeric_expression, 336)
			"phys":
				return _matches_property(item, numeric_expression, 425)
			"fdmg":
				return _matches_property(item, numeric_expression, 329)
			"ldmg":
				return _matches_property(item, numeric_expression, 330)
			"cdmg":
				return _matches_property(item, numeric_expression, 331)
			"pdmg":
				return _matches_property(item, numeric_expression, 332)
			"mdmg":
				return _matches_property(item, numeric_expression, 357)
			"flatpdr":
				return _matches_property(item, numeric_expression, 34)
			"mdr":
				return _matches_property(item, numeric_expression, 35)
			"pdr":
				return _matches_property(item, numeric_expression, 36)
			"fhr":
				return _matches_property(item, numeric_expression, 99)
			"fbr":
				return _matches_property(item, numeric_expression, 102)
			"frw":
				return _matches_property(item, numeric_expression, 96)
			"plr":
				return _matches_property(item, numeric_expression, 110)
			"clr":
				return _matches_property(item, numeric_expression, 109)
			"ed":
				return _matches_property(item, numeric_expression, 17)
			"ias":
				return _matches_property(item, numeric_expression, 93)
			"fcr":
				return _matches_property(item, numeric_expression, 105)
			"edef":
				return _matches_property(item, numeric_expression, 16)
			"life":
				return _matches_property(item, numeric_expression, 7)
			"mana":
				return _matches_property(item, numeric_expression, 9)
			"maxlife":
				return _matches_property(item, numeric_expression, 76)
			"maxmana":
				return _matches_property(item, numeric_expression, 77)
			"str":
				return _matches_property(item, numeric_expression, 0)
			"eng":
				return _matches_property(item, numeric_expression, 1)
			"dex":
				return _matches_property(item, numeric_expression, 2)
			"vit":
				return _matches_property(item, numeric_expression, 3)
			"all":
				return _matches_property(item, numeric_expression, 0) and \
				_matches_property(item, numeric_expression, 1) and \
				_matches_property(item, numeric_expression, 2) and \
				_matches_property(item, numeric_expression, 3)
			"ar":
				return _matches_property(item, numeric_expression, 19)
			"arper":
				return _matches_property(item, numeric_expression, 119)
			"ds":
				return _matches_property(item, numeric_expression, 141)
			"maxds":
				return _matches_property(item, numeric_expression, 210)
			"dsm":
				return _matches_property(item, numeric_expression, 257)
			"cb":
				return _matches_property(item, numeric_expression, 136)
			"cbe":
				return _matches_property(item, numeric_expression, 268)
			"cs":
				return _matches_property(item, numeric_expression, 258)
			"ow":
				return _matches_property(item, numeric_expression, 135)
			"owdmg":
				return _matches_property(item, numeric_expression, 501)
			"pierce":
				return _matches_property(item, numeric_expression, 156)
			"skills":
				return _matches_property(item, numeric_expression, 127)
			"mf":
				return _matches_property(item, numeric_expression, 80)
			"gf":
				return _matches_property(item, numeric_expression, 79)
			"maek":
				return _matches_property(item, numeric_expression, 138)
			"laek":
				return _matches_property(item, numeric_expression, 86)
			"xp":
				return _matches_property(item, numeric_expression, 85)
			"lifesteal":
				return _matches_property(item, numeric_expression, 60)
			"manasteal":
				return _matches_property(item, numeric_expression, 62)
			"block":
				return _matches_property(item, numeric_expression, 20)
			"regen":
				return _matches_property(item, numeric_expression, 27)
			"curse":
				return _matches_property(item, numeric_expression, 504)
			"atd":
				return _matches_property(item, numeric_expression, 78)
			"atld":
				return _matches_property(item, numeric_expression, 128)
			"replife":
				return _matches_property(item, numeric_expression, 74)
			"mapmf":
				return _matches_property(item, numeric_expression, 370)
			"mapgf":
				return _matches_property(item, numeric_expression, 371)
			"mapden":
				return _matches_property(item, numeric_expression, 372)
			"mapxp":
				return _matches_property(item, numeric_expression, 373)
			"maprar":
				return _matches_property(item, numeric_expression, 375)
			"dtm":
				return _matches_property(item, numeric_expression, 114)
			"hfd":
				return _matches_property(item, numeric_expression, 118)
			"cbf":
				return _matches_property(item, numeric_expression, 153)
			"itd":
				return _matches_property(item, numeric_expression, 115)
			"eth":
				return item.is_ethereal
			_:
				return false
	
	func _matches_property(item: D2Item, numeric_expression: NumericExpression, stat_id: int) -> bool:
		for prop: Dictionary in item.all_properties:
			if prop.stat_id == stat_id:
				return NumericExpression.matches(numeric_expression, prop.params[0])
		return false
	
	func _compile_single_term(term: String, negated: bool) -> Dictionary:
		var numeric_expression := NumericExpression.parse(term)
		if numeric_expression.is_valid:
			return { "kind": TermKind.NUMERIC, "numeric_expression": numeric_expression, "negated": negated, "complete": true}
		elif term.begins_with("t:") or term.begins_with("type:"):
			var term_complete := term.split(":", false).size() > 1
			return { "kind": TermKind.TYPE, "value": term, "negated": negated, "complete": term_complete}
		elif term.begins_with("b:") or term.begins_with("base:"):
			var term_complete := term.split(":", false).size() > 1
			return { "kind": TermKind.BASE, "value": term, "negated": negated, "complete": term_complete}
		elif term.begins_with("r:") or term.begins_with("rarity:"):
			var term_complete := term.split(":", false).size() > 1
			return { "kind": TermKind.RARITY, "value": term, "negated": negated, "complete": term_complete }
		elif term.begins_with("tier:"):
			var term_complete := term.split(":", false).size() > 1
			return { "kind": TermKind.TIER, "value": term, "negated": negated, "complete": term_complete }
		# Text fallback
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
			TermKind.BASE:
				result = _matches_base_filter(item, compiled_term.value)
			TermKind.RARITY:
				result = _matches_rarity_filter(item, compiled_term.value)
			TermKind.TIER:
				result = _matches_tier_filter(item, compiled_term.value)
			TermKind.NUMERIC:
				result = _matches_numeric_filter(item, compiled_term.numeric_expression)
			
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


class NumericExpression:
	enum Operator {EQUAL, GREATER, GREATER_EQUAL, LOWER, LOWER_EQUAL, RANGE, EXISTS}
	
	const VALID_KEYS: Dictionary[String, bool] = {
		"reqlvl": true,
		"reqdex": true,
		"reqstr": true,
		"ilvl": true,
		"sock": true,
		"def": true,
		"dmg": true,
		"res": true,
		"fres": true,
		"lres": true,
		"cres": true,
		"pres": true,
		"ares": true,
		"maxfres": true,
		"maxlres": true,
		"maxcres": true,
		"maxpres": true,
		"maxres": true,
		"fabs": true,
		"flatfabs": true,
		"labs": true,
		"flatlabs": true,
		"cabs": true,
		"flatcabs": true,
		"min": true,
		"max": true,
		"dam": true,
		"fmin": true,
		"fmax": true,
		"lmin": true,
		"lmax": true,
		"mmin": true,
		"mmax": true,
		"cmin": true,
		"cmax": true,
		"pmin": true,
		"pmax": true,
		"fpierce": true,
		"lpierce": true,
		"cpierce": true,
		"ppierce": true,
		"phys": true,
		"fdmg": true,
		"ldmg": true,
		"cdmg": true,
		"pdmg": true,
		"mdmg": true,
		"flatpdr": true,
		"mdr": true,
		"pdr": true,
		"fhr": true,
		"fbr": true,
		"frw": true,
		"plr": true,
		"clr": true,
		"ed": true,
		"ias": true,
		"fcr": true,
		"edef": true,
		"life": true,
		"mana": true,
		"maxlife": true,
		"maxmana": true,
		"str": true,
		"eng": true,
		"dex": true,
		"vit": true,
		"all": true,
		"ar": true,
		"arper": true,
		"ds": true,
		"maxds": true,
		"dsm": true,
		"cb": true,
		"cbe": true,
		"cs": true,
		"ow": true,
		"owdmg": true,
		"pierce": true,
		"skills": true,
		"mf": true,
		"gf": true,
		"maek": true,
		"laek": true,
		"xp": true,
		"lifesteal": true,
		"manasteal": true,
		"block": true,
		"regen": true,
		"curse": true,
		"atd": true,
		"atld": true,
		"replife": true,
		"mapmf": true,
		"mapgf": true,
		"mapden": true,
		"mapxp": true,
		"maprar": true,
		"dtm": true,
		"hfd": true,
		"cbf": true,
		"itd": true,
		"eth": true,
	}
	
	var key: String
	var operator: Operator
	var value: int
	var min_value: int
	var max_value: int
	
	var is_valid: bool
	
	
	static func parse(input: String) -> NumericExpression:
		var expression := NumericExpression.new()
		input = input.strip_edges()
		
		var num_regex := RegEx.create_from_string(r"^([a-zA-Z_][a-zA-Z0-9_]*)(?:\s*(<=|>=|=|<|>|~)\s*((?:-?\d+)|(?:-?\d+\s*-\s*-?\d+)))?$")
		var num_result := num_regex.search(input)
		if not num_result:
			return expression
		expression.key = num_result.strings[1]
		if not NumericExpression.VALID_KEYS.has(expression.key):
			return expression
		if num_result.strings[2].is_empty():
			expression.operator = Operator.EXISTS
			expression.is_valid = true
			return expression
		match num_result.strings[2]:
			"<=":
				expression.operator = Operator.LOWER_EQUAL
			">=":
				expression.operator = Operator.GREATER_EQUAL
			"=":
				expression.operator = Operator.EQUAL
			"<":
				expression.operator = Operator.LOWER
			">":
				expression.operator = Operator.GREATER
			"~":
				expression.operator = Operator.RANGE
		if expression.operator == Operator.RANGE:
			var value_regex := RegEx.create_from_string(r"^(-?\d+)\s*-\s*(-?\d+)$")
			var value_result := value_regex.search(num_result.strings[3])
			if value_result:
				expression.min_value = int(value_result.strings[1])
				expression.max_value = int(value_result.strings[2])
				if expression.min_value <= expression.max_value:
					expression.is_valid = true
		else:
			var value_regex := RegEx.create_from_string(r"^(-?\d+)$")
			var value_result := value_regex.search(num_result.strings[3])
			if value_result:
				expression.value = int(value_result.strings[1])
				expression.is_valid = true
		return expression
	
	
	static func matches(expression: NumericExpression, op_value: int) -> bool:
		match expression.operator:
			Operator.EXISTS:
				return true
			Operator.EQUAL:
				return op_value == expression.value
			Operator.GREATER:
				return op_value > expression.value
			Operator.GREATER_EQUAL:
				return op_value >= expression.value
			Operator.LOWER:
				return op_value < expression.value
			Operator.LOWER_EQUAL:
				return op_value <= expression.value
			Operator.RANGE:
				return op_value >= expression.min_value and op_value <= expression.max_value

		return false
