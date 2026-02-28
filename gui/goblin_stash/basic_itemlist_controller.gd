@abstract
class_name BasicItemListController

@warning_ignore("unused_signal")
signal item_selected(item: D2Item)
@warning_ignore("unused_signal")
signal sort_requested(sort_key: ItemSorter.SortKey, sort_ascending: bool)

enum RestoreSelection {NONE, BY_INDEX, BY_ITEM}
enum RestoreFallback {NONE, FIRST_INDEX, LAST_INDEX}

# Selection
@warning_ignore("unused_private_class_variable")
var _prev_selected_index: int
@warning_ignore("unused_private_class_variable")
var _prev_selected_item: D2Item


@warning_ignore("unused_parameter")
func accept_sort(sort_key: ItemSorter.SortKey, sort_ascending: bool) -> void:
	pass
@abstract func rebuild_display(items: Array[D2Item]) -> void
@abstract func restore_last_selection(restore_selection: RestoreSelection, restore_fallback := RestoreFallback.NONE) -> void
