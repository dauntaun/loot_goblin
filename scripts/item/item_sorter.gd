class_name ItemSorter

enum SortKey {NAME, TYPE, ETH, CORRUPT, SOCKETS}


static func sort_items(items: Array[D2Item], sort_key: SortKey, ascending: bool) -> void:
	match sort_key:
		SortKey.NAME:
			items.sort_custom(_sort_by_name)
		SortKey.TYPE:
			items.sort_custom(_sort_by_type)
		SortKey.ETH:
			items.sort_custom(_sort_by_eth)
		SortKey.CORRUPT:
			items.sort_custom(_sort_by_corrupt)
		SortKey.SOCKETS:
			items.sort_custom(_sort_by_sockets)
	if not ascending:
		items.reverse()


static func _sort_by_name(a: D2Item, b: D2Item) -> int:
	return a.item_name.naturalnocasecmp_to(b.item_name) < 0


static func _sort_by_type(a: D2Item, b: D2Item) -> int:
	if a.item_type == b.item_type:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	return a.item_type < b.item_type


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
