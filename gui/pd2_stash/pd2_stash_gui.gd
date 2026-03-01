class_name PD2StashGUI
extends TabContainer

var _initialized: bool
var _pd2_pages: PagedStashView
var _item_page_map: Dictionary[D2Item, int]

var _materials_page: MaterialsPageGUI # index 0
var _personal_page: StashPageGUI # index 1
var _shared_pages: Array[StashPageGUI] # indeces 2-11


func _ready() -> void:
	for i: int in get_tab_count():
		set("tab_%d/disabled" % i, true)
	
	_materials_page = get_child(0)
	_personal_page = get_child(1)
	for i: int in range(2, 11):
		var stash_page := get_child(i) as StashPageGUI
		stash_page.item_selected.connect(_on_item_selected_in_shared_stash)
		_shared_pages.append(stash_page)
	
	
	tab_changed.connect(_on_tab_changed)
	_personal_page.item_selected.connect(_on_item_selected_in_personal_stash)


func init_shared_pages(pd2_pages: PagedStashView, materials_page: MaterialsPage) -> void:
	if _initialized:
		cleanup_connections()
	_pd2_pages = pd2_pages
	_populate_shared_stash_pages(_pd2_pages)
	for i: int in range(2, get_tab_count()):
		set("tab_%d/disabled" % i, false)
	_pd2_pages.item_added.connect(_on_item_added_in_shared_stash)
	_pd2_pages.item_removed.connect(_on_item_removed_from_shared_stash)
	init_materials_page(materials_page)
	_initialized = true


func cleanup_connections() -> void:
	_pd2_pages.item_added.disconnect(_on_item_added_in_shared_stash)
	_pd2_pages.item_removed.disconnect(_on_item_removed_from_shared_stash)


func init_materials_page(materials_page: MaterialsPage) -> void:
	set("tab_0/disabled", false)
	_materials_page.init_materials(materials_page)


func init_personal_page(items: Array[D2Item]) -> void:
	set("tab_1/disabled", false)
	_personal_page.init_page(items)


func _populate_shared_stash_pages(pd2_pages: PagedStashView) -> void:
	for page_index: int in _shared_pages.size():
		var stash_page: StashPageGUI = _shared_pages[page_index]
		var items := pd2_pages.get_items_in_page(page_index)
		stash_page.init_page(items)
		for item: D2Item in items:
			_item_page_map[item] = page_index


func _on_item_added_in_shared_stash(item: D2Item) -> void:
	var page_index := item.equipped_id - 1
	_shared_pages[page_index].add_item_rect(item)
	_item_page_map[item] = page_index


func _on_item_removed_from_shared_stash(item: D2Item) -> void:
	var page_index := _item_page_map[item]
	_shared_pages[page_index].remove_item(item)
	_item_page_map.erase(item)


func _on_tab_changed(tab: int) -> void:
	ItemSelection.clear_selection()
	if tab > 1:
		ItemSelection.set_destination_page_index(tab - 2)
		_shared_pages[tab - 2].restore_last_selection()


func _on_item_selected_in_shared_stash(item: D2Item) -> void:
	var items_in_page := _pd2_pages.get_items_in_page(current_tab - 2)
	ItemSelection.set_selection(item, StashRegistry.StashType.PD2_SHARED, items_in_page)
	_shared_pages[current_tab - 2].select_item(item)


func _on_item_selected_in_personal_stash(_item: D2Item) -> void:
	pass


func restore_last_selection() -> void:
	if current_tab > 1:
		_shared_pages[current_tab - 2].restore_last_selection()
