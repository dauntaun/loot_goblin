extends Tree

enum ColType {NAME, ETH, BASE, TIER, QLVL, TC}

var categories := ["Weapon", "Armor", "Misc"]
var weapons := ["Axe 1H", "Axe 2H", "Mace 1H", "Mace 2H", "Sword 1H", "Sword 2H", "Dagger", "Throwing", "Spear", "Polearm", "Bow", "Crossbow", "Staff", "Wand", "Scepter", "Claw", "Orb", "Amazon"]
var armors := ["Helm", "Circlet", "Armor", "Shield", "Gloves", "Boots", "Belt", "Druid Helm", "Barbarian Helm", "Paladin Shield", "Necromancer Shield"]
var misc := ["Arrows", "Bolts", "Amulet", "Ring", "Charm", "Jewel", "Map"]
var uber := ["DClone", "Rathma"]


@onready var unique_filters: QuickFiltersGUI = %GrailFiltersUnique
@onready var set_filters: QuickFiltersGUI = %GrailFiltersSet
@onready var grail_switcher: TabSwitcher = %GrailSwitcher

var _uniques_filtered: Array[GrailEntry]
var _sets_filtered: Array[GrailEntry]


func _ready() -> void:
	unique_filters.quick_filter_changed.connect(_filter_uniques)
	set_filters.quick_filter_changed.connect(_filter_sets)
	grail_switcher.tab_switched.connect(_switch_grail)
	# Columns
	columns = 6
	set_column_title(ColType.NAME, "Name")
	set_column_title(ColType.BASE, "Base")
	#set_column_title(ColType.TYPE, "Type")
	set_column_title(ColType.TIER, "Tier")
	set_column_title(ColType.TC, "TC")
	set_column_title(ColType.QLVL, "qLvL")
	set_column_title(ColType.ETH, "Eth")
	set_column_expand_ratio(ColType.NAME, 6)
	set_column_expand_ratio(ColType.BASE, 3)
	set_column_expand_ratio(ColType.TIER, 2)
	set_column_expand(ColType.ETH, false)
	set_column_title_alignment(ColType.BASE, HORIZONTAL_ALIGNMENT_LEFT)
	set_column_title_alignment(ColType.TIER, HORIZONTAL_ALIGNMENT_LEFT)
	set_column_title_alignment(ColType.TC, HORIZONTAL_ALIGNMENT_LEFT)
	set_column_title_alignment(ColType.QLVL, HORIZONTAL_ALIGNMENT_LEFT)
	set_column_title_alignment(ColType.ETH, HORIZONTAL_ALIGNMENT_LEFT)
	await get_tree().physics_frame
	update_grail()


func update_grail() -> void:
	Grail.update_grail()
	_uniques_filtered = Grail.grail_uniques.values()
	_sets_filtered = Grail.grail_sets.values()
	_rebuild_tree(_uniques_filtered)
	
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
		var button_string: String = "\n" + "(%d/%d)" % \
			[Grail.set_completion_by_subcategory[category].found, Grail.set_completion_by_subcategory[category].total]
		button.text += button_string
	
	var unique_string := "\n" + "(%d/%d)" % [Grail.unique_total_completion.found, Grail.unique_total_completion.total]
	grail_switcher.switch_buttons[0].text += unique_string
	
	var set_string := "\n" + "(%d/%d)" % [Grail.set_total_completion.found, Grail.set_total_completion.total]
	grail_switcher.switch_buttons[1].text += set_string


func _rebuild_tree(entries: Array[GrailEntry]) -> void:
	clear()
	create_item() # Root
	for entry: GrailEntry in entries:
		var row := create_item()
		row.set_text(ColType.NAME, entry.item_name)
		row.set_text(ColType.BASE, entry.item_base_name)
		if entry.found:
			var color := D2Colors.COLOR_UNIQUE if entry.item_rarity == D2Item.ItemRarity.UNIQUE else D2Colors.COLOR_SET
			row.set_custom_color(ColType.NAME, color)
		else:
			row.set_custom_color(ColType.NAME, D2Colors.COLOR_GRAY)
		row.set_text(ColType.TIER, entry.item_tier)
		row.set_text(ColType.TC, entry.item_tc)
		if entry.item_tc == "TC87":
			row.set_custom_color(ColType.TC, D2Colors.COLOR_CRAFTED)
		row.set_text(ColType.QLVL, str(entry.item_qlvl))
		if entry.eth_possible:
			row.set_cell_mode(ColType.ETH, TreeItem.CELL_MODE_CHECK)
			row.set_checked(ColType.ETH, entry.found_eth)


func _filter_uniques(filter: String, values: Array[int]) -> void:
	_uniques_filtered.clear()
	for unique_entry: GrailEntry in Grail.grail_uniques.values():
		if _entry_matches_filters(unique_entry, filter, values):
			_uniques_filtered.append(unique_entry)
	_rebuild_tree(_uniques_filtered)


func _filter_sets(filter: String, values: Array[int]) -> void:
	_sets_filtered.clear()
	for set_entry: GrailEntry in Grail.grail_sets.values():
		if _entry_matches_filters(set_entry, filter, values):
			_sets_filtered.append(set_entry)
	_rebuild_tree(_sets_filtered)


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
	if index == 0:
		_rebuild_tree(_uniques_filtered)
	else:
		_rebuild_tree(_sets_filtered)
