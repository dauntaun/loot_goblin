class_name GoblinStashGUI
extends Control

const MAX_ITEMS_PER_PAGE := 150

# Main panel
@onready var tree: Tree = %TreeView
@onready var tiled_container: MasonryContainer = %GridView
@onready var table_view_button: Button = %TableView
@onready var tile_view_button: Button = %TileView

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

var _current_itemlist_controller: BasicItemListController
var _table_controller: BasicItemListController
var _tiled_controller: TiledItemListController


func _ready() -> void:
	# Setup item list controllers
	_table_controller = TableItemListController.new(tree)
	_table_controller.item_selected.connect(_on_item_selected)
	_table_controller.sort_requested.connect(_on_sort_requested)
	_tiled_controller = TiledItemListController.new(tiled_container)
	_tiled_controller.item_selected.connect(_submit_new_query)
	_current_itemlist_controller = _table_controller
	table_view_button.pressed.connect(_switch_itemlist_controller.bind(_table_controller))
	tile_view_button.pressed.connect(_switch_itemlist_controller.bind(_tiled_controller))
	
	_item_searcher = ItemSearcher.new()
	_search_bar.query_submitted.connect(_submit_new_query)
	quick_filters.quick_filter_changed.connect(_on_quick_filters_changed)
	ItemSelection.items_transferred.connect(_on_items_transferred)
	CommandQueue.queue_undone.connect(_reset_page_and_refresh_filters.bind(false))
	
	_next_page_button.pressed.connect(_next_page)
	_prev_page_button.pressed.connect(_prev_page)


func init_stash(stash_view: BasicStashView) -> void:
	_item_searcher = ItemSearcher.new(stash_view)
	_item_searcher.filter_outdated.connect(_reset_page_and_refresh_filters)
	_reset_page_and_refresh_filters()


func _on_quick_filters_changed(quick_filter: String, values: Array[int]) -> void:
	match quick_filter:
		"type":
			_item_searcher.set_quick_filters(ItemSearchQuery.QuickFilter.TYPE, values)
		"rarity":
			_item_searcher.set_quick_filters(ItemSearchQuery.QuickFilter.RARITY, values)
		"tier":
			_item_searcher.set_quick_filters(ItemSearchQuery.QuickFilter.TIER, values)
		"property":
			_item_searcher.set_quick_filters(ItemSearchQuery.QuickFilter.PROPERTY, values)
	
	_reset_page_and_refresh_filters()
	_current_itemlist_controller.restore_last_selection(BasicItemListController.RestoreSelection.BY_ITEM)


func _submit_new_query(string_query: String) -> void:
	_item_searcher.set_typed_filter(string_query)
	
	_reset_page_and_refresh_filters()
	_current_itemlist_controller.restore_last_selection(BasicItemListController.RestoreSelection.BY_ITEM)


func _reset_page_and_refresh_filters(restore_selection: bool = true) -> void:
	_current_page = 0
	_item_searcher.filter_and_sort()
	_refresh_current_page(restore_selection)


func _refresh_current_page(restore_selection: bool = true) -> void:
	var items := _item_searcher.get_filtered_items()
	var start := _current_page * MAX_ITEMS_PER_PAGE
	var end: int = min(start + MAX_ITEMS_PER_PAGE, items.size())

	_items_in_page = items.slice(start, end)
	_current_itemlist_controller.rebuild_display(_items_in_page)
	ItemSelection.clear_selection()
	if restore_selection: 
		_table_controller.restore_last_selection(BasicItemListController.RestoreSelection.BY_ITEM)
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
	return maxi(0, (_item_searcher.get_filtered_items().size() - 1) / MAX_ITEMS_PER_PAGE)


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
	_table_controller.restore_last_selection(BasicItemListController.RestoreSelection.BY_INDEX, BasicItemListController.RestoreFallback.LAST_INDEX)


func _on_items_stored() -> void:
	_item_searcher.apply_sort()
	_refresh_current_page(false)


func _on_sort_requested(sort_key: ItemSorter.SortKey, sort_ascending: bool) -> void:
	_item_searcher.set_sort(sort_key, sort_ascending)
	_item_searcher.apply_sort()
	_refresh_current_page()
	_table_controller.restore_last_selection(BasicItemListController.RestoreSelection.BY_ITEM)


func _refresh_buttons() -> void:
	var max_page := _get_max_page()
	_page_label.text = "Page %d of %d" % [_current_page + 1, max_page + 1]
	
	_prev_page_button.disabled = _current_page == 0
	_next_page_button.disabled = _current_page >= max_page
	var item_count := _item_searcher.get_filtered_items().size()
	var start := _current_page * MAX_ITEMS_PER_PAGE
	var end: int = min(start + MAX_ITEMS_PER_PAGE, item_count)
	if max_page > 0:
		_item_count_label.text = "(%d to %d) of %d items" % [start + 1, end, item_count]
	else:
		_item_count_label.text = "%d items" % item_count


func _on_item_selected(item: D2Item) -> void:
	ItemSelection.set_selection(item, StashRegistry.StashType.GOBLIN, _items_in_page)


func restore_last_selection() -> void:
	_table_controller.restore_last_selection(BasicItemListController.RestoreSelection.BY_ITEM)


func _switch_itemlist_controller(controller: BasicItemListController) -> void:
	_current_itemlist_controller = controller
	_reset_page_and_refresh_filters()
