class_name GoblinSaveFile
extends BasicSaveFile

# Main header
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
		collections.append(collection)
	
	if not collections[0].name == MAIN_COLLECTION_NAME:
		push_error("Unknown main collection")
		return
	
	load_successful= true


func save_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if data.is_empty():
		write_header()
	for collection: GoblinCollection in collections:
		collection.item_list.write_item_count()
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
	main.write_header()
	main.name = MAIN_COLLECTION_NAME
	main.write_name()
	main.write_itemlist_header()


class GoblinCollection:
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
		var collection := GoblinCollection.new(start_bit << 3, cursor._data)
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
	
	
	func write_header() -> void:
		_data.encode_u16(_start_byte, COLLECTION_HEADER)
	
	
	func write_name() -> void:
		var name_bytes := name.to_ascii_buffer()
		if name_bytes.size() != COLLECTION_NAME_BYTE_LENGTH:
			name_bytes.append(0)
		for i: int in name_bytes.size():
			_data.encode_u8(_start_byte + COLLECTION_NAME_BYTE_OFFSET + i, name_bytes[i])
	
	
	func write_itemlist_header() -> void:
		_data.encode_u16(_start_byte + ITEM_LIST_BYTE_OFFSET, ItemParser.ITEM_SIGNATURE)
	
	
	
	
