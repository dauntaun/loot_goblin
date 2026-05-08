class_name ItemSearcher

signal filter_outdated

var _source_stashes: Array[BasicStashView]
var _source_items: Array[D2Item]
var _filtered_items: Array[D2Item]

var _search_query: ItemSearchQuery
var _resync_items_required: bool = true # Needed for first sync, and when item list mutates
var _sorting_required: bool = true # When an item is added

var _sort_key: ItemSorter.SortKey
var _sort_ascending: bool = true


func _init(sources: Array[BasicStashView] = []) -> void:
	_search_query = ItemSearchQuery.new()
	if not sources:
		return
	set_source_stashes(sources)


func set_source_stashes(sources: Array[BasicStashView]) -> void:
	for stash: BasicStashView in _source_stashes:
		stash.item_removed.disconnect(_on_item_removed)
		stash.item_added.disconnect(_on_item_added)
		stash.items_imported.disconnect(_on_item_list_modified)
		stash.list_cleared.disconnect(_on_item_list_modified)
	_source_stashes.clear()
	_source_items.clear()

	for stash: BasicStashView in sources:
		_source_stashes.append(stash)
		_source_items.append_array(stash.get_items())

		stash.item_removed.connect(_on_item_removed)
		stash.item_added.connect(_on_item_added)
		stash.items_imported.connect(_on_item_list_modified)
		stash.list_cleared.connect(_on_item_list_modified)

	_resync_items_required = true
	filter_outdated.emit()


func has_stash_id(stash_id: int) -> bool:
	for stash: BasicStashView in _source_stashes:
		if stash.stash_id == stash_id:
			return true
	return false


func set_quick_filters(quick_filter: ItemSearchQuery.QuickFilter, values: Array[int]) -> void:
	_search_query.set_quick_filter(quick_filter, values)


func reset_quick_filters() -> void:
	_search_query.reset_quick_filters()


func set_typed_filter(typed_query: String) -> void:
	_search_query.set_string_query(typed_query)


func get_filtered_items() -> Array[D2Item]:
	return _filtered_items


func apply_sort() -> void:
	ItemSorter.sort_items(_filtered_items, _sort_key, _sort_ascending)
	_sorting_required = false


func set_sort(sort_key: ItemSorter.SortKey, sort_ascending: bool) -> void:
	_sort_key = sort_key
	_sort_ascending = sort_ascending


func get_sort_key() -> ItemSorter.SortKey:
	return _sort_key


func get_sort_ascending() -> bool:
	return _sort_ascending


func filter_and_sort(force_resync := false, force_sort := false) -> Array[D2Item]:
	var source_items: Array[D2Item]
	
	var resync_required := force_resync or not _search_query.can_filter_incrementally() or _resync_items_required
	if not resync_required:
		source_items = _filtered_items
	else:
		_source_items.clear()
		for stash: BasicStashView in _source_stashes:
			_source_items.append_array(stash.get_items())
		source_items = _source_items
		_resync_items_required = false
	
	var new_items: Array[D2Item]
	for item: D2Item in source_items:
		if _search_query.matches(item):
			new_items.append(item)
	_filtered_items = new_items # As long as we are calling the getter sync is safe
	if resync_required or force_sort or _sorting_required:
		apply_sort()
	
	_search_query.mark_applied()
	return _filtered_items


func _on_item_removed(item: D2Item) -> void:
	_filtered_items.erase(item)


func _on_item_added(item: D2Item) -> void:
	if _search_query.matches(item):
		_filtered_items.append(item)
		_sorting_required = true


func _on_item_list_modified() -> void:
	_resync_items_required = true
	_sorting_required = true
	filter_outdated.emit()
