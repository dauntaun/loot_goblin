class_name PD2SaveFile
extends BasicSaveFile

const FILE_SIGNATURE := 0xBB55BB55 # 85,187,85,187
const FILE_VERSION := 2
const ITEM_LIST_BYTE_OFFSET: int = 302

var header: D2SaveHeader
var materials_page: MaterialsPage
var item_list: D2ItemList


func load_file() -> void:
	var signature := data.decode_u32(0)
	if signature != FILE_SIGNATURE:
		push_error("Unknown PD2 file header")
		return
	var file_version := data.decode_u16(4)
	if file_version != FILE_VERSION:
		push_error("Unknown PD2 file version")
		return
	load_successful = true
	
	header = D2SaveHeader.new(data)
	var cursor := BitCursor.new(data, ITEM_LIST_BYTE_OFFSET << 3)
	item_list = D2ItemList.new(cursor)
	materials_page = MaterialsPage.new(data)


func save_file(path: String) -> void:
	item_list.write_item_count()
	header.update_file_size()
	header.write_checksum()
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(data)
	file.close()
	save_timestamp = FileAccess.get_modified_time(path)
	load_timestamp = FileAccess.get_access_time(path)
