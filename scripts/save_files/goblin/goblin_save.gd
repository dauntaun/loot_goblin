class_name GoblinSaveFile
extends BasicSaveFile

# Main header
const FILE_HEADER := 0x00424F47 ## GOB
const FILE_VERSION_BYTE_OFFSET := 4 ## 2 bytes
const FILE_VERSION_ONE := 1
const COLLECTIONS_COUNT_BYTE_OFFSET := 48 ## 2 bytes
const MAIN_COLLECTION_START_BYTE_OFFSET := 50

# Collections header
const COLLECTION_HEADER := 0x4743 ## GC / 2 bytes
const COLLECTION_NAME_BYTE_OFFSET := 20 ## Relative to start
const COLLECTION_NAME_BYTE_LENGTH := 50 ## Null terminates string
const MAIN_COLLECTION_NAME := "Main"
const ITEM_LIST_BYTE_OFFSET := 70 ## Relative to start
const ITEM_COUNT_BYTE_OFFSET := 72 ## Relative to start

var item_list: D2ItemList


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
	
	# Collections parsing
	var collection_header := data.decode_u16(MAIN_COLLECTION_START_BYTE_OFFSET)
	if collection_header != COLLECTION_HEADER:
		push_error("Unknown Goblin collection header")
		return
	var collection_name: String = ""
	for i: int in COLLECTION_NAME_BYTE_LENGTH:
		var char_code := data.decode_u8(MAIN_COLLECTION_START_BYTE_OFFSET + COLLECTION_NAME_BYTE_OFFSET + i)
		if char_code == 0:
			break
		collection_name += char(char_code)
	if collection_name != MAIN_COLLECTION_NAME:
		push_error("Unknown Main collection name")
		return
	load_successful = true
	var cursor := BitCursor.new(data, (MAIN_COLLECTION_START_BYTE_OFFSET + ITEM_LIST_BYTE_OFFSET) << 3)
	item_list = D2ItemList.new(cursor)


func save_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if data.is_empty():
		write_header()
	if item_list:
		write_item_count(item_list.get_item_count())
	file.store_buffer(data)
	file.close()
	save_timestamp = FileAccess.get_modified_time(path)
	load_timestamp = FileAccess.get_access_time(path)


func write_item_count(count: int) -> void:
	data.encode_u16(MAIN_COLLECTION_START_BYTE_OFFSET + ITEM_COUNT_BYTE_OFFSET, count)


func write_header() -> void:
	data.resize(124)
	# Main header
	data.encode_u32(0, FILE_HEADER)
	data.encode_u16(FILE_VERSION_BYTE_OFFSET, FILE_VERSION_ONE)
	data.encode_u16(COLLECTIONS_COUNT_BYTE_OFFSET, 1)
	# Main collection header
	data.encode_u16(MAIN_COLLECTION_START_BYTE_OFFSET, COLLECTION_HEADER)
	# Encode name
	var name_bytes := MAIN_COLLECTION_NAME.to_ascii_buffer()
	if name_bytes.size() != COLLECTION_NAME_BYTE_LENGTH:
		name_bytes.append(0)
	for i: int in name_bytes.size():
		data.encode_u8(MAIN_COLLECTION_START_BYTE_OFFSET + COLLECTION_NAME_BYTE_OFFSET + i, name_bytes[i])
	
	data.encode_u16(MAIN_COLLECTION_START_BYTE_OFFSET + ITEM_LIST_BYTE_OFFSET, ItemParser.ITEM_SIGNATURE)
