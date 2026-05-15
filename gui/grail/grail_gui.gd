extends Tree

enum TreeType {UNIQUE, SET, RUNEWORD}

enum UniqueColType {NAME, ETH, BASE, TIER, QLVL, TC}
enum RunewordColType {NAME, SOCKETS, RUNES, ITYPE, RLVL}

var categories := ["Weapon", "Armor", "Misc"]
var weapons := ["Axe 1H", "Axe 2H", "Mace 1H", "Mace 2H", "Sword 1H", "Sword 2H", "Dagger", "Throwing", "Spear", "Polearm", "Bow", "Crossbow", "Staff", "Wand", "Scepter", "Claw", "Orb", "Amazon"]
var armors := ["Helm", "Circlet", "Chest", "Shield", "Gloves", "Boots", "Belt", "Druid Helm", "Barbarian Helm", "Paladin Shield", "Necromancer Shield"]
var misc := ["Arrows", "Bolts", "Amulet", "Ring", "Charm", "Jewel", "Map"]
var uber := ["DClone", "Rathma"]

@onready var unique_filters: QuickFiltersGUI = %GrailFiltersUnique
@onready var set_filters: QuickFiltersGUI = %GrailFiltersSet
@onready var rune_filters: QuickFiltersGUI = %GrailFiltersRunes
@onready var grail_switcher: TabSwitcher = %GrailSwitcher

var _uniques_filtered: Array[GrailEntry]
var _sets_filtered: Array[GrailEntry]
var _runewords_filtered: Array[RunewordEntry]
var _current_tree: TreeType


func _ready() -> void:
	unique_filters.quick_filter_changed.connect(_filter_uniques)
	set_filters.quick_filter_changed.connect(_filter_sets)
	rune_filters.quick_filter_changed.connect(_filter_runewords)
	grail_switcher.tab_switched.connect(_switch_grail)
	await get_tree().physics_frame
	update_grail()


func switch_tree(new_tree: TreeType) -> void:
	_current_tree = new_tree
	if new_tree in [TreeType.UNIQUE, TreeType.SET]:
		columns = 6
		set_column_title(UniqueColType.NAME, "Name")
		set_column_title(UniqueColType.BASE, "Base")
		set_column_title(UniqueColType.TIER, "Tier")
		set_column_title(UniqueColType.TC, "TC")
		set_column_title(UniqueColType.QLVL, "qLvL")
		set_column_title(UniqueColType.ETH, "Eth")
		set_column_expand_ratio(UniqueColType.NAME, 6)
		set_column_expand_ratio(UniqueColType.BASE, 3)
		set_column_expand_ratio(UniqueColType.TIER, 2)
		set_column_expand(UniqueColType.ETH, false)
		set_column_title_alignment(UniqueColType.BASE, HORIZONTAL_ALIGNMENT_LEFT)
		set_column_title_alignment(UniqueColType.TIER, HORIZONTAL_ALIGNMENT_LEFT)
		set_column_title_alignment(UniqueColType.TC, HORIZONTAL_ALIGNMENT_LEFT)
		set_column_title_alignment(UniqueColType.QLVL, HORIZONTAL_ALIGNMENT_LEFT)
		set_column_title_alignment(UniqueColType.ETH, HORIZONTAL_ALIGNMENT_LEFT)
		if new_tree == TreeType.UNIQUE:
			_rebuild_unique_tree(_uniques_filtered)
		else:
			_rebuild_unique_tree(_sets_filtered)
	elif new_tree == TreeType.RUNEWORD:
		columns = 5
		set_column_title(RunewordColType.NAME, "Name")
		set_column_title(RunewordColType.RUNES, "Runes")
		set_column_title(RunewordColType.SOCKETS, "Soc")
		set_column_title(RunewordColType.ITYPE, "Types")
		set_column_title(RunewordColType.RLVL, "rLvL")
		set_column_expand_ratio(RunewordColType.NAME, 6)
		#set_column_expand_ratio(RunewordColType.RUNES, 2)
		set_column_expand_ratio(RunewordColType.ITYPE, 5)
		set_column_expand(RunewordColType.SOCKETS, false)
		set_column_title_alignment(RunewordColType.NAME, HORIZONTAL_ALIGNMENT_LEFT)
		set_column_title_alignment(RunewordColType.RUNES, HORIZONTAL_ALIGNMENT_LEFT)
		set_column_title_alignment(RunewordColType.SOCKETS, HORIZONTAL_ALIGNMENT_CENTER)
		set_column_title_alignment(RunewordColType.ITYPE, HORIZONTAL_ALIGNMENT_LEFT)
		set_column_title_alignment(RunewordColType.RLVL, HORIZONTAL_ALIGNMENT_CENTER)
		set_column_custom_minimum_width(RunewordColType.RUNES, 135)
		_rebuild_runeword_tree()


func update_grail() -> void:
	Grail.update_grail()
	_uniques_filtered = Grail.grail_uniques.values()
	_sets_filtered = Grail.grail_sets.values()
	_runewords_filtered = Grail.grail_runewords.values()
	switch_tree(TreeType.UNIQUE)
	
	for title: String in unique_filters.filter_titles:
		var title_label: Label = unique_filters.filter_titles[title]
		var title_string := title + " (%d/%d)" % \
			[Grail.unique_completion_by_main_category[title].found, Grail.unique_completion_by_main_category[title].total]
		title_label.text = title_string
	
	var weapon_buttons: Array[Button]
	var armor_buttons: Array[Button]
	var misc_buttons: Array[Button]
	var uber_buttons: Array[Button]
	for category: String in unique_filters.filters:
		match category:
			"Weapon":
				weapon_buttons.append_array(unique_filters.filters[category].get_children())
			"Armor":
				armor_buttons.append_array(unique_filters.filters[category].get_children())
			"Misc":
				misc_buttons.append_array(unique_filters.filters[category].get_children())
			"Uber":
				uber_buttons.append_array(unique_filters.filters[category].get_children())
	var all_buttons: Array[Button]
	all_buttons.append_array(weapon_buttons)
	all_buttons.append_array(armor_buttons)
	all_buttons.append_array(misc_buttons)
	all_buttons.append_array(uber_buttons)
	for i: int in all_buttons.size():
		var button := all_buttons[i]
		var category: String = Grail.unique_subcategories[i]
		if Grail.unique_completion_by_subcategory[category].missing != 0:
			button.add_theme_color_override("font_color", D2Colors.COLOR_GRAY)
		var button_string: String = "\n" + "(%d/%d)" % \
			[Grail.unique_completion_by_subcategory[category].found, Grail.unique_completion_by_subcategory[category].total]
		button.text += button_string
	
	for title: String in set_filters.filter_titles:
		var title_label: Label = set_filters.filter_titles[title]
		var title_string := title + " (%d/%d)" % \
			[Grail.set_completion_by_main_category[title].found, Grail.set_completion_by_main_category[title].total]
		title_label.text = title_string
	
	var common_buttons: Array[Button]
	var uncommon_buttons: Array[Button]
	var class_buttons: Array[Button]
	for category: String in set_filters.filters:
		match category:
			"Common":
				common_buttons.append_array(set_filters.filters[category].get_children())
			"Uncommon":
				uncommon_buttons.append_array(set_filters.filters[category].get_children())
			"Class-Focused":
				class_buttons.append_array(set_filters.filters[category].get_children())
	all_buttons.clear()
	all_buttons.append_array(common_buttons)
	all_buttons.append_array(uncommon_buttons)
	all_buttons.append_array(class_buttons)
	for i: int in all_buttons.size():
		var button := all_buttons[i]
		var category: String = Grail.set_subcategories[i]
		if Grail.set_completion_by_subcategory[category].missing != 0:
			button.add_theme_color_override("font_color", D2Colors.COLOR_GRAY)
		var button_string: String = "\n" + "(%d/%d)" % \
			[Grail.set_completion_by_subcategory[category].found, Grail.set_completion_by_subcategory[category].total]
		button.text += button_string
	
	var unique_string := "\n" + "(%d/%d)" % [Grail.unique_total_completion.found, Grail.unique_total_completion.total]
	grail_switcher.switch_buttons[0].text += unique_string
	
	var set_string := "\n" + "(%d/%d)" % [Grail.set_total_completion.found, Grail.set_total_completion.total]
	grail_switcher.switch_buttons[1].text += set_string
	
	var rw_string := "\n" + "(%d/%d)" % [Grail.rw_total_completion.found, Grail.rw_total_completion.total]
	grail_switcher.switch_buttons[2].text += rw_string


func _rebuild_unique_tree(entries: Array[GrailEntry]) -> void:
	clear()
	create_item() # Root
	for entry: GrailEntry in entries:
		var row := create_item()
		row.set_text(UniqueColType.NAME, entry.item_name)
		row.set_text(UniqueColType.BASE, entry.item_base_name)
		if entry.found:
			var color := D2Colors.COLOR_UNIQUE if entry.item_rarity == D2Item.ItemRarity.UNIQUE else D2Colors.COLOR_SET
			row.set_custom_color(UniqueColType.NAME, color)
		else:
			row.set_custom_color(UniqueColType.NAME, D2Colors.COLOR_GRAY)
		row.set_text(UniqueColType.TIER, entry.item_tier)
		row.set_text(UniqueColType.TC, entry.item_tc)
		if entry.item_tc == "TC87":
			row.set_custom_color(UniqueColType.TC, D2Colors.COLOR_CRAFTED)
		row.set_text(UniqueColType.QLVL, str(entry.item_qlvl))
		if entry.eth_possible:
			row.set_cell_mode(UniqueColType.ETH, TreeItem.CELL_MODE_CHECK)
			row.set_checked(UniqueColType.ETH, entry.found_eth)


func _rebuild_runeword_tree() -> void:
	clear()
	create_item() # Root
	for entry: RunewordEntry in _runewords_filtered:
		var row := create_item()
		row.set_text(RunewordColType.NAME, entry.rw_name)
		if entry.found:
			row.set_custom_color(RunewordColType.NAME, D2Colors.COLOR_UNIQUE)
		else:
			row.set_custom_color(RunewordColType.NAME, D2Colors.COLOR_GRAY)
		row.set_text(RunewordColType.RUNES, entry.runes)
		#row.set_custom_color(RunewordColType.RUNES, D2Colors.COLOR_UNIQUE)
		row.set_text(RunewordColType.SOCKETS, str(entry.sockets))
		row.set_text_alignment(RunewordColType.SOCKETS, HORIZONTAL_ALIGNMENT_CENTER)
		row.set_text(RunewordColType.ITYPE, entry.itypes)
		row.set_text(RunewordColType.RLVL, str(entry.req_level))
		row.set_text_alignment(RunewordColType.RLVL, HORIZONTAL_ALIGNMENT_CENTER)


func _filter_uniques(filter: String, values: Array[int]) -> void:
	_uniques_filtered.clear()
	for unique_entry: GrailEntry in Grail.grail_uniques.values():
		if _entry_matches_filters(unique_entry, filter, values):
			_uniques_filtered.append(unique_entry)
	_rebuild_unique_tree(_uniques_filtered)


func _filter_sets(filter: String, values: Array[int]) -> void:
	_sets_filtered.clear()
	for set_entry: GrailEntry in Grail.grail_sets.values():
		if _entry_matches_filters(set_entry, filter, values):
			_sets_filtered.append(set_entry)
	_rebuild_unique_tree(_sets_filtered)


func _filter_runewords(filter: String, values: Array[int]) -> void:
	_runewords_filtered.clear()
	for rw_entry: RunewordEntry in Grail.grail_runewords.values():
		var all_runes_match: bool = true
		for value: int in values:
			var rune_string: String = rune_filters.filters[filter].get_child(value).text
			if not rw_entry.runes.contains(rune_string):
				all_runes_match = false
		if all_runes_match:
			_runewords_filtered.append(rw_entry)
	_rebuild_runeword_tree()


func _entry_matches_filters(entry: GrailEntry , filter: String, values: Array[int]) -> bool:
	if values.is_empty():
		return true
	match filter:
		"Weapon":
			return entry.subcategory == weapons[values[0]]
		"Armor":
			return entry.subcategory == armors[values[0]]
		"Misc":
			return entry.subcategory == misc[values[0]]
		"Uber":
			return entry.subcategory == uber[values[0]]
		"Common":
			return entry.subcategory == Grail.common_sets[values[0]]
		"Uncommon":
			return entry.subcategory == Grail.uncommon_sets[values[0]]
		"Class-Focused":
			return entry.subcategory == Grail.class_focused_sets[values[0]]
	return true


func _switch_grail(index: int) -> void:
	match index:
		0:
			switch_tree(TreeType.UNIQUE)
		1:
			switch_tree(TreeType.SET)
		2:
			switch_tree(TreeType.RUNEWORD)
