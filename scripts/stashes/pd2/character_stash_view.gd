class_name CharacterStashView
extends BasicStashView

var _personal_page_grid: InventoryGrid
var _inventory_grid: InventoryGrid
var _cube_grid: InventoryGrid


func _init(items: Array[D2Item], id: int) -> void:
	_personal_page_grid = InventoryGrid.new()
	_inventory_grid = InventoryGrid.new(10, 8)
	_cube_grid = InventoryGrid.new(4, 4)
	_init_items(items)
	super(items, id)


func add_item(item: D2Item) -> void:
	var coord := item.get_coord()
	match item.store_id:
		D2Item.StoreLocation.STASH, D2Item.StoreLocation.PD2_STASH:
			_personal_page_grid.add_item_at_coord(item, coord)
		D2Item.StoreLocation.INVENTORY:
			_inventory_grid.add_item_at_coord(item, coord)
		D2Item.StoreLocation.CUBE:
			_cube_grid.add_item_at_coord(item, coord)
	super(item)


func remove_item(item: D2Item) -> void:
	match item.store_id:
		D2Item.StoreLocation.STASH, D2Item.StoreLocation.PD2_STASH:
			_personal_page_grid.remove_item(item)
		D2Item.StoreLocation.INVENTORY:
			_inventory_grid.remove_item(item)
		D2Item.StoreLocation.CUBE:
			_cube_grid.remove_item(item)
	super(item)


func can_add_items(
		items: Array[D2Item],
		page_index: int,
		item_location := D2Item.ItemLocation.STORED,
		store_location := D2Item.StoreLocation.NONE) -> bool:
	
	match item_location:
			D2Item.ItemLocation.EQUIPPED:
				if items.size() != 1:
					return false
				for item: D2Item in get_equipped_items():
					if item.equipped_id == page_index:
						return false
				return true
			D2Item.ItemLocation.STORED:
				match store_location:
					D2Item.StoreLocation.STASH, D2Item.StoreLocation.PD2_STASH:
						return _personal_page_grid.can_fit_items(items)
					D2Item.StoreLocation.INVENTORY:
						return _inventory_grid.can_fit_items(items)
					D2Item.StoreLocation.CUBE:
						return _cube_grid.can_fit_items(items)
					_:
						return false
			_:
				return false


func get_placement(
		item: D2Item,
		page_index: int,
		item_location := D2Item.ItemLocation.STORED,
		store_location := D2Item.StoreLocation.STASH) -> ItemPlacement:
	var placement := ItemPlacement.new()
	match item_location:
		D2Item.ItemLocation.STORED:
			placement.equipped_id = D2Item.EquipLocation.NONE
			placement.location_id = item_location
			placement.store_id = D2Item.StoreLocation.PD2_STASH
			match store_location:
				D2Item.StoreLocation.STASH, D2Item.StoreLocation.PD2_STASH:
					placement.coord = _personal_page_grid.find_space(item)
					placement.store_id = D2Item.StoreLocation.PD2_STASH
				D2Item.StoreLocation.INVENTORY:
					placement.coord = _inventory_grid.find_space(item)
					placement.store_id = store_location
				D2Item.StoreLocation.CUBE:
					placement.coord = _cube_grid.find_space(item)
					placement.store_id = store_location
		D2Item.ItemLocation.EQUIPPED:
			placement.location_id = D2Item.ItemLocation.EQUIPPED
			placement.equipped_id = page_index as D2Item.EquipLocation
			placement.store_id = D2Item.StoreLocation.NONE
	return placement


func _init_items(items: Array[D2Item]) -> void:
	for item: D2Item in items:
		if item.location_id == D2Item.ItemLocation.STORED:
			match item.store_id:
				D2Item.StoreLocation.STASH, D2Item.StoreLocation.PD2_STASH:
					_personal_page_grid.add_item_at_coord(item, item.get_coord())
				D2Item.StoreLocation.INVENTORY:
					_inventory_grid.add_item_at_coord(item, item.get_coord())
				D2Item.StoreLocation.CUBE:
					_cube_grid.add_item_at_coord(item, item.get_coord())
