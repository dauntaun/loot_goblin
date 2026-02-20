class_name GoblinStashGUI
extends Control

const TREE_MAX_ITEMS_PER_PAGE := 150

# Main panel
@onready var tree_view: StashTreeView = %TreeView
# Left panel
@onready var quick_filters: QuickFiltersGUI = %QuickFilters
# Bottom panel
@onready var _search_bar: SearchBar = %SearchBar
@onready var _prev_page_button: Button = %PagePrev
@onready var _next_page_button: Button = %PageNext
@onready var _page_label: Label = %PageLabel
@onready var _item_count_label: Label = %ItemCount

var _item_searcher: ItemSearcher
var _current_page: int
var _items_in_page: Array[D2Item]


func _ready() -> void:
	_item_searcher = ItemSearcher.new()
	_search_bar.query_submitted.connect(_submit_new_query)
	tree_view.item_clicked.connect(_on_item_selected)
	tree_view.sort_requested.connect(_on_sort_requested)
	quick_filters.quick_filter_changed.connect(_on_quick_filters_changed)
	ItemSelection.items_transferred.connect(_on_items_transferred)
	CommandQueue.queue_undone.connect(_reset_page_and_refresh_filters.bind(false))
	
	_next_page_button.pressed.connect(_next_page)
	_prev_page_button.pressed.connect(_prev_page)


func init_stash(stash_view: BasicStashView) -> void:
	_item_searcher = ItemSearcher.new(stash_view)
	_item_searcher.filter_outdated.connect(_reset_page_and_refresh_filters)
	_reset_page_and_refresh_filters()


func _on_quick_filters_changed(quick_filter: ItemSearchQuery.QuickFilter, new_values: Array[int]) -> void:
	_item_searcher.set_quick_filters(quick_filter, new_values)
	
	_reset_page_and_refresh_filters()
	tree_view.restore_last_selection(StashTreeView.RestoreSelection.BY_ITEM)


func _submit_new_query(string_query: String) -> void:
	_item_searcher.set_typed_filter(string_query)
	
	_reset_page_and_refresh_filters()
	tree_view.restore_last_selection(StashTreeView.RestoreSelection.BY_ITEM)


func _reset_page_and_refresh_filters(restore_selection: bool = true) -> void:
	_current_page = 0
	_item_searcher.filter_and_sort()
	_refresh_current_page(restore_selection)


func _refresh_current_page(restore_selection: bool = true) -> void:
	var items := _item_searcher.get_filtered_items()
	var start := _current_page * TREE_MAX_ITEMS_PER_PAGE
	var end: int = min(start + TREE_MAX_ITEMS_PER_PAGE, items.size())

	_items_in_page = items.slice(start, end)
	tree_view.rebuild_display(_items_in_page)
	ItemSelection.clear_selection()
	if restore_selection: 
		tree_view.restore_last_selection(StashTreeView.RestoreSelection.BY_ITEM)
	_refresh_buttons()


func _next_page() -> void:
	if _current_page < _get_max_page():
		_current_page += 1
		_refresh_current_page()


func _prev_page() -> void:
	if _current_page > 0:
		_current_page -= 1
		_refresh_current_page()


func _get_max_page() -> int:
	return maxi(0, (_item_searcher.get_filtered_items().size() - 1) / TREE_MAX_ITEMS_PER_PAGE)


func _clamp_current_page_index() -> void:
	_current_page = clamp(_current_page, 0, _get_max_page())


func _on_items_transferred(from: StashRegistry.StashType, to: StashRegistry.StashType) -> void:
	if from == StashRegistry.StashType.GOBLIN:
		_on_items_retrieved()
	elif to == StashRegistry.StashType.GOBLIN:
		_on_items_stored()


func _on_items_retrieved() -> void:
	_clamp_current_page_index()
	_refresh_current_page()
	tree_view.restore_last_selection(StashTreeView.RestoreSelection.BY_INDEX, StashTreeView.RestoreFallback.LAST_INDEX)


func _on_items_stored() -> void:
	_item_searcher.apply_sort()
	_refresh_current_page(false)


func _on_sort_requested(sort_key: ItemSorter.SortKey, sort_ascending: bool) -> void:
	_item_searcher.set_sort(sort_key, sort_ascending)
	_item_searcher.apply_sort()
	_refresh_current_page()
	tree_view.restore_last_selection(StashTreeView.RestoreSelection.BY_ITEM)


func _refresh_buttons() -> void:
	var max_page := _get_max_page()
	_page_label.text = "Page %d of %d" % [_current_page + 1, max_page + 1]
	
	_prev_page_button.disabled = _current_page == 0
	_next_page_button.disabled = _current_page >= max_page
	var item_count := _item_searcher.get_filtered_items().size()
	var start := _current_page * TREE_MAX_ITEMS_PER_PAGE
	var end: int = min(start + TREE_MAX_ITEMS_PER_PAGE, item_count)
	if max_page > 0:
		_item_count_label.text = "(%d to %d) of %d items" % [start + 1, end, item_count]
	else:
		_item_count_label.text = "%d items" % item_count


func _on_item_selected(item: D2Item) -> void:
	ItemSelection.set_selection(item, StashRegistry.StashType.GOBLIN, _items_in_page)


func restore_last_selection() -> void:
	tree_view.restore_last_selection(StashTreeView.RestoreSelection.BY_ITEM)
	
