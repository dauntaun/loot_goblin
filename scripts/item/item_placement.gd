class_name ItemPlacement

var coord: Vector2i
var equipped_id: D2Item.EquipLocation
var store_id: D2Item.StoreLocation


static func from_item(item: D2Item) -> ItemPlacement:
	var placement := ItemPlacement.new()
	placement.coord = item.get_coord()
	placement.equipped_id = item.equipped_id
	placement.store_id = item.store_id
	return placement


func matches_item(item: D2Item) -> bool:
	return coord == item.get_coord() \
	and equipped_id == item.equipped_id \
	and store_id == item.store_id


func matches_placement(placement: ItemPlacement) -> bool:
	return coord == placement.coord \
	and equipped_id == placement.equipped_id \
	and store_id == placement.store_id


func apply_to_item(item: D2Item) -> void:
	item.x_coord = coord.x
	item.y_coord = coord.y
	item.equipped_id = equipped_id
	item.store_id = store_id
