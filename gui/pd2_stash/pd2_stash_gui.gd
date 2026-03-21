class_name PD2StashGUI
extends TabContainer

var _initialized_shared: bool
var _initialized_personal: bool
var _pd2_pages: PagedStashView
var _char_view: CharacterStashView
var _item_page_map: Dictionary[D2Item, int]

var _materials_page: MaterialsPageGUI # index 0
var _personal_page: StashPageGUI # index 1
var _personal_view: CharacterStashView
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
	StashRegistry.pd2_shared_registered.connect(func() -> void:
		current_tab = GlobalSettings.pd2_stash_page + 1
		var materials_page := StashRegistry.get_pd2_shared_save_file().materials_page
		var pd2_pages := StashRegistry.get_stash_view(StashRegistry.get_pd2_shared_stash_id())
		init_shared_pages(pd2_pages, materials_page))


func init_shared_pages(pd2_pages: PagedStashView, materials_page: MaterialsPage) -> void:
	if _initialized_shared:
		cleanup_shared_connections()
	_pd2_pages = pd2_pages
	_populate_shared_stash_pages(_pd2_pages)
	for i: int in range(2, get_tab_count()):
		set("tab_%d/disabled" % i, false)
	_pd2_pages.item_added.connect(_on_item_added_in_shared_stash)
	_pd2_pages.item_removed.connect(_on_item_removed_from_shared_stash)
	init_materials_page(materials_page)
	_initialized_shared = true


func cleanup_shared_connections() -> void:
	_pd2_pages.item_added.disconnect(_on_item_added_in_shared_stash)
	_pd2_pages.item_removed.disconnect(_on_item_removed_from_shared_stash)


func cleanup_personal_connections() -> void:
	_personal_view.item_added.disconnect(_on_item_added_in_personal_stash)
	_personal_view.item_removed.disconnect(_on_item_removed_from_personal_stash)


func init_materials_page(materials_page: MaterialsPage) -> void:
	set("tab_0/disabled", false)
	_materials_page.init_materials(materials_page)


func init_personal_page(stash_view: CharacterStashView) -> void:
	if _initialized_personal:
		cleanup_personal_connections()
	_char_view = stash_view
	set("tab_1/disabled", false)
	stash_view.item_added.connect(_on_item_added_in_personal_stash)
	stash_view.item_removed.connect(_on_item_removed_from_personal_stash)
	_personal_page.init_page(stash_view.get_stashed_items())
	_personal_view = stash_view
	_initialized_personal = true


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


func _on_item_added_in_personal_stash(item: D2Item) -> void:
	if item.location_id == D2Item.ItemLocation.STORED and item.store_id == D2Item.StoreLocation.PD2_STASH:
		_personal_page.add_item_rect(item)


func _on_item_removed_from_personal_stash(item: D2Item) -> void:
	if item.location_id == D2Item.ItemLocation.STORED and item.store_id == D2Item.StoreLocation.PD2_STASH:
		_personal_page.remove_item(item)


func _on_tab_changed(tab: int) -> void:
	ItemSelection.clear_selection()
	if tab == 1:
		_personal_page.restore_last_selection()
	if tab > 1:
		ItemSelection.set_destination_page_index(tab - 2)
		_shared_pages[tab - 2].restore_last_selection()


func _on_item_selected_in_shared_stash(item: D2Item) -> void:
	var items_in_page := _pd2_pages.get_items_in_page(current_tab - 2)
	ItemSelection.set_selection(item, _pd2_pages.stash_id, items_in_page)
	_shared_pages[current_tab - 2].select_item(item)


func _on_item_selected_in_personal_stash(item: D2Item) -> void:
	var items_in_page := _char_view.get_stashed_items()
	ItemSelection.set_selection(item, _char_view.stash_id, items_in_page)
	_personal_page.select_item(item)


func restore_last_selection() -> void:
	if current_tab == 1:
		_personal_page.restore_last_selection()
	elif current_tab > 1:
		_shared_pages[current_tab - 2].restore_last_selection()
