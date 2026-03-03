class_name D2ItemList

signal list_cleared
signal items_imported
signal bytes_shifted(delta: int)

var _data: PackedByteArray
var _start_byte: int
var _end_byte: int

var _items: Array[D2Item]
var _parsed_item_count: int


func _init(cursor: BitCursor) -> void:
	_data = cursor._data # cursor at JM item list header
	if _data.is_empty():
		return
	if _data.decode_u16(cursor._bit_pos>>3) != ItemParser.ITEM_SIGNATURE:
		push_error("Invalid item list header")
		return
	cursor.discard_bits(16) # cursor at item count header
	_parsed_item_count = cursor.read_bits(16) # cursor at first item JM header
	_start_byte = cursor._bit_pos >> 3
	_items = ItemParser.parse_item_list_at_cursor(cursor, _parsed_item_count, self)
	_end_byte = cursor._bit_pos >> 3


func get_items() -> Array[D2Item]:
	return _items


func get_itemlist() -> BasicStashView:
	return BasicStashView.new(_items.duplicate())


func get_pd2pages() -> PagedStashView:
	return PagedStashView.new(_items.duplicate())


func get_parsed_item_count() -> int:
	return _parsed_item_count


func get_item_count() -> int:
	return _items.size()


func _append_items_from_list(item_list: D2ItemList) -> void:
	if item_list._items.is_empty():
		return
	
	var end_offset := _end_byte - _start_byte
	
	for item: D2Item in item_list._items:
		_items.append(item)
		ItemRegistry.item_data_register[item.item_id] = self
		item.start_offset = end_offset
		end_offset += item.length
	var new_bytes: PackedByteArray = item_list.get_bytes()
	BitFieldIO.insert_section(_data, _end_byte, new_bytes)
	var delta := new_bytes.size()
	_end_byte += delta
	bytes_shifted.emit(delta)


func import_item_lists(item_lists: Array[D2ItemList]) -> void:
	for item_list: D2ItemList in item_lists:
		_append_items_from_list(item_list)
	items_imported.emit()


func add_item_bytes(item: D2Item, item_bytes: PackedByteArray) -> void:
	item.start_offset = _end_byte - _start_byte

	# Bookkeeping
	BitFieldIO.insert_section(_data, _end_byte, item_bytes)
	var delta := item_bytes.size()
	_end_byte += delta
	_items.append(item)
	ItemRegistry.item_data_register[item.item_id] = self
	bytes_shifted.emit(delta)


func get_item_bytes(item: D2Item) -> PackedByteArray:
	var item_start_byte := _start_byte + item.start_offset
	var item_bytes := _data.slice(item_start_byte, item_start_byte + item.length)
	return item_bytes


func has_item_bytes(item: D2Item) -> bool:
	return _items.has(item)


## Removes the item data and returns it's bytes
func extract_item_bytes(item: D2Item) -> PackedByteArray:
	var item_bytes := get_item_bytes(item)
	delete_item_bytes(item)
	return item_bytes


func delete_item_bytes(item: D2Item) -> void:
	if not _items.has(item):
		push_error("Item not found in item list")
		return

	var item_start_offset := item.start_offset
	var item_start_byte := _start_byte + item_start_offset
	var item_length := item.length

	BitFieldIO.remove_section(_data, item_start_byte, item_length)
	_end_byte -= item_length
	_items.erase(item)

	# Fix offsets for remaining entries
	for other: D2Item in _items:
		if other.start_offset > item_start_offset:
			other.start_offset -= item_length
	
	bytes_shifted.emit(-item_length)


func write_current_item_position(item: D2Item) -> void:
	var item_start_byte: int = _start_byte + item.start_offset
	ItemWriter.write_field(_data, item_start_byte, ItemWriter.WriteableField.X_COORD, item.x_coord)
	ItemWriter.write_field(_data, item_start_byte, ItemWriter.WriteableField.Y_COORD, item.y_coord)
	ItemWriter.write_field(_data, item_start_byte, ItemWriter.WriteableField.EQUIPPED_ID, item.equipped_id)
	ItemWriter.write_field(_data, item_start_byte, ItemWriter.WriteableField.STORE_ID, item.store_id)


func clear_list() -> void:
	if _items.is_empty():
		return

	var items_begin_byte: int = _start_byte + _items[0].start_offset
	var items_length: int = _end_byte - items_begin_byte

	BitFieldIO.remove_section(_data, items_begin_byte, items_length)
	_end_byte -= items_length

	_items.clear()
	list_cleared.emit()
	bytes_shifted.emit(-items_length)


# List getters
func get_start_byte() -> int:
	return _start_byte


func get_end_byte() -> int:
	return _end_byte


func get_bytes() -> PackedByteArray:
	return _data.slice(_start_byte, _end_byte)
