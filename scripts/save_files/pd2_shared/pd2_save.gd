class_name PD2SaveFile
extends BasicSaveFile

var header: PD2Header
var materials_page: MaterialsPage
var item_list: D2ItemList


func load_file() -> void:
	var cursor := BitCursor.new(data)
	header = PD2Header.new(cursor)
	if not header.parse_successful:
		return
	load_successful = true
	item_list = D2ItemList.new(cursor)
	materials_page = MaterialsPage.new(data)


func save_file(path: String) -> void:
	header.write_item_count(item_list.get_item_count())
	header.update_file_size()
	header.write_checksum()
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(data)
	file.close()
	save_timestamp = FileAccess.get_modified_time(path)
	load_timestamp = FileAccess.get_access_time(path)
