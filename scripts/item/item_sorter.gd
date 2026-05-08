class_name ItemSorter

enum SortKey {NAME, TYPE, BASE, ETH, CORRUPT, SOCKETS, DAM, DEF, RES, ILVL, STASH}


static func sort_items(items: Array[D2Item], sort_key: SortKey, ascending: bool) -> void:
	match sort_key:
		SortKey.NAME:
			items.sort_custom(_sort_by_name)
		SortKey.TYPE:
			items.sort_custom(_sort_by_type)
		SortKey.BASE:
			items.sort_custom(_sort_by_base)
		SortKey.ETH:
			items.sort_custom(_sort_by_eth)
		SortKey.CORRUPT:
			items.sort_custom(_sort_by_corrupt)
		SortKey.SOCKETS:
			items.sort_custom(_sort_by_sockets)
		SortKey.DAM:
			items.sort_custom(_sort_by_damage)
		SortKey.DEF:
			items.sort_custom(_sort_by_defense)
		SortKey.RES:
			items.sort_custom(_sort_by_total_res)
		SortKey.ILVL:
			items.sort_custom(_sort_by_ilvl)
		SortKey.STASH:
			items.sort_custom(_sort_by_stash_id)
	if not ascending:
		items.reverse()


static func _sort_by_name(a: D2Item, b: D2Item) -> int:
	return a.item_name.naturalnocasecmp_to(b.item_name) < 0


static func _sort_by_type(a: D2Item, b: D2Item) -> int:
	if a.item_type == b.item_type:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	return a.item_type < b.item_type


static func _sort_by_base(a: D2Item, b: D2Item) -> int:
	if a.base_name == b.base_name:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	return a.base_name < b.base_name


static func _sort_by_eth(a: D2Item, b: D2Item) -> int:
	if a.is_ethereal == b.is_ethereal:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	return a.is_ethereal > b.is_ethereal


static func _sort_by_corrupt(a: D2Item, b: D2Item) -> int:
	if a.is_corrupted == b.is_corrupted:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	return a.is_corrupted > b.is_corrupted


static func _sort_by_sockets(a: D2Item, b: D2Item) -> int:
	if a.total_sockets == b.total_sockets:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	return a.total_sockets > b.total_sockets


static func _sort_by_damage(a: D2Item, b: D2Item) -> int:
	if a.average_damage == b.average_damage:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	return a.average_damage > b.average_damage


static func _sort_by_defense(a: D2Item, b: D2Item) -> int:
	if a.defense == b.defense:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	return a.defense > b.defense


static func _sort_by_total_res(a: D2Item, b: D2Item) -> int:
	if a.total_res == b.total_res:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	return a.total_res > b.total_res


static func _sort_by_ilvl(a: D2Item, b: D2Item) -> int:
	if a.item_level == b.item_level:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	return a.item_level > b.item_level


static func _sort_by_stash_id(a: D2Item, b: D2Item) -> int:
	var a_id := ItemRegistry.item_view_register[a.item_id]
	var b_id := ItemRegistry.item_view_register[b.item_id]
	if a_id == b_id:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	return a_id > b_id
