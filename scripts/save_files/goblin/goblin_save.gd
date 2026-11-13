class_name GoblinSaveFile
extends BasicSaveFile

# Main header 50 bytes
const FILE_HEADER := 0x00424F47 ## GOB
const FILE_VERSION_BYTE_OFFSET := 4 ## 2 bytes
const FILE_VERSION_ONE := 1
const COLLECTIONS_COUNT_BYTE_OFFSET := 48 ## 2 bytes
const MAIN_COLLECTION_START_BYTE_OFFSET := 50
const MAIN_COLLECTION_NAME := "Main"

var collections: Array[GoblinCollection]


func load_file() -> void:
	# Main parsing
	var header := data.decode_u32(0)
	if header != FILE_HEADER:
		push_error("Unknown Goblin file header")
		return
	var file_version := data.decode_u16(FILE_VERSION_BYTE_OFFSET)
	if file_version != FILE_VERSION_ONE:
		push_error("Unknown Goblin file version")
		return
	var collections_count := data.decode_u16(COLLECTIONS_COUNT_BYTE_OFFSET)
	if collections_count < 1:
		push_error("No Goblin collections found in save file")
		return
	
	# Collections parsing
	var cursor := BitCursor.new(data, MAIN_COLLECTION_START_BYTE_OFFSET << 3)
	for i: int in collections_count:
		var collection := GoblinCollection.from_cursor(cursor)
		if not collection.item_list.init_successful:
			return
		collections.append(collection)
		collection.item_list.bytes_shifted.connect(_update_collection_offsets)
	
	if not collections[0].name == MAIN_COLLECTION_NAME:
		push_error("Unknown main collection")
		return
	
	load_successful = true


func save_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if data.is_empty():
		write_header()
	for collection: GoblinCollection in collections:
		collection.item_list.write_item_count()
	data.encode_u16(COLLECTIONS_COUNT_BYTE_OFFSET, collections.size())
	file.store_buffer(data)
	file.close()
	save_timestamp = FileAccess.get_modified_time(path)
	load_timestamp = FileAccess.get_access_time(path)


func write_header() -> void:
	data.resize(124)
	# Main header
	data.encode_u32(0, FILE_HEADER)
	data.encode_u16(FILE_VERSION_BYTE_OFFSET, FILE_VERSION_ONE)
	data.encode_u16(COLLECTIONS_COUNT_BYTE_OFFSET, 1)
	# Main collection header
	var main := GoblinCollection.new(MAIN_COLLECTION_START_BYTE_OFFSET, data)
	main.name = MAIN_COLLECTION_NAME
	main.write_headers()
	main.init_item_list()
	collections.append(main)


func add_collection(name: String) -> GoblinCollection:
	var start_byte := data.size()
	data.resize(start_byte + 74)
	var collection := GoblinCollection.new(start_byte, data)
	collection.name = name
	collection.write_headers()
	collection.init_item_list()
	
	collections.append(collection)
	collection.item_list.bytes_shifted.connect(_update_collection_offsets)
	return collection


func insert_collection_at_index(collection: GoblinCollection, index: int) -> void:
	pass


func rename_collection(collection_id: int, new_name: String) -> void:
	var collection := get_collection_from_id(collection_id)
	collection.name = new_name
	collection.write_name()


func delete_collection(collection_id: int) -> void:
	var collection := get_collection_from_id(collection_id)
	var start_byte := collection._start_byte
	var length := collection.item_list.get_end_byte() - start_byte
	BitFieldIO.remove_section(data, start_byte, length)
	collections.erase(collection)
	
	_update_collection_offsets(-length, start_byte)


func _update_collection_offsets(delta: int, from_offset: int) -> void:
	for collection: GoblinCollection in collections:
		if collection._start_byte > from_offset:
			collection._start_byte += delta
			collection.item_list._start_byte += delta
			collection.item_list._end_byte += delta


func get_collection_from_id(collection_id: int) -> GoblinCollection:
	for collection: GoblinCollection in collections:
		if collection.collection_id == collection_id:
			return collection
	return null


class GoblinCollection: # 74 bytes
	const COLLECTION_HEADER := 0x4743 ## GC / 2 bytes
	const COLLECTION_NAME_BYTE_OFFSET := 20 ## Relative to start
	const COLLECTION_NAME_BYTE_LENGTH := 50 ## Null terminates string
	const ITEM_LIST_BYTE_OFFSET := 70 ## Relative to start
	
	static var collection_id_counter := 0
	
	var collection_id: int
	var name: String
	var item_list: D2ItemList
	
	var _start_byte: int
	var _data: PackedByteArray
	
	
	func _init(start_byte: int, data: PackedByteArray) -> void:
		_start_byte = start_byte
		_data = data
		collection_id = collection_id_counter
		collection_id_counter += 1
	
	
	static func from_cursor(cursor: BitCursor) -> GoblinCollection:
		var start_bit := cursor._bit_pos
		var collection := GoblinCollection.new(start_bit >> 3, cursor._data)
		var collection_header := cursor.read_bits(2 << 3)
		if collection_header != COLLECTION_HEADER:
			push_error("Unknown Goblin collection header")
			return
		cursor.set_at(start_bit + (COLLECTION_NAME_BYTE_OFFSET << 3))
		var collection_name: String = ""
		for i: int in COLLECTION_NAME_BYTE_LENGTH:
			var char_code := cursor.read_bits(8)
			if char_code == 0:
				break
			collection_name += char(char_code)
		collection.name = collection_name
		cursor.set_at(start_bit + (ITEM_LIST_BYTE_OFFSET << 3))
		collection.item_list = D2ItemList.new(cursor)
		return collection
	
	
	func write_headers() -> void:
		_data.encode_u16(_start_byte, COLLECTION_HEADER) # Collection header
		write_name()
		_data.encode_u16(_start_byte + ITEM_LIST_BYTE_OFFSET, ItemParser.ITEM_SIGNATURE) # Item list header
	
	
	func init_item_list() -> void:
		var cursor := BitCursor.new(_data, (_start_byte + ITEM_LIST_BYTE_OFFSET) << 3)
		item_list = D2ItemList.new(cursor)
	
	
	func write_name() -> void:
		var name_bytes := name.to_ascii_buffer()
		if name_bytes.size() >= COLLECTION_NAME_BYTE_LENGTH:
			push_error("Collection name is too long")
			return
			
		for i: int in COLLECTION_NAME_BYTE_LENGTH:
			var char_byte := name_bytes[i] if i < name_bytes.size() else 0
			_data.encode_u8(_start_byte + COLLECTION_NAME_BYTE_OFFSET + i, char_byte)
