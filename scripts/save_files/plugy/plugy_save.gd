class_name PlugySaveFile
extends BasicSaveFile

const SHARED_STASH_HEADER: int = 0x00535353 ## SSS
const PERSONAL_STASH_HEADER: int = 0x4D545343 ## CSTM
const FILE_VERSION_BYTE_OFFSET: int = 4
const FILE_VERSION_ONE: int = 0x3130 ## 01
const FILE_VERSION_TWO: int = 0x3230 ## 02
const STASH_PAGE_SIGNATURE: int = 0x5453 ## ST

var stash_pages: Array[PlugyStashPage]


func load_file() -> void:
	var header := data.decode_u32(0)
	var file_version := data.decode_u16(FILE_VERSION_BYTE_OFFSET)
	# Decide begin byte depending on file version
	var begin_byte: int
	if header == SHARED_STASH_HEADER:
		if file_version == FILE_VERSION_ONE:
			begin_byte = 10
		elif file_version == FILE_VERSION_TWO:
			begin_byte = 14
		else:
			push_error("Unknown PlugY file version")
			return
	elif header == PERSONAL_STASH_HEADER:
		begin_byte = 14
	else:
		push_error("Unknown PlugY file header")
		return
	load_successful = true
	# Parse stash pages
	var cursor := BitCursor.new(data, begin_byte << 3)
	while true:
		if not cursor.can_read(2 << 3):
			return
		elif cursor._data.decode_u16(cursor._bit_pos>>3) == STASH_PAGE_SIGNATURE:
			var plugy_page := PlugyStashPage.new(cursor)
			stash_pages.append(plugy_page)
		else:
			return


func save_file(_path: String) -> void:
	return


func get_total_item_count() -> int:
	var total_count: int = 0
	for page: PlugyStashPage in stash_pages:
		var item_count: int = page.item_list.get_item_count()
		total_count += item_count
	return total_count


func get_page_count() -> int:
	return stash_pages.size()


func get_all_item_lists() -> Array[D2ItemList]:
	var item_lists: Array[D2ItemList]
	for page: PlugyStashPage in stash_pages:
		item_lists.append(page.item_list)
	return item_lists


class PlugyStashPage:
	const FLAGS_BYTE_OFFSET := 2
	const FLAGS_BYTE_LENGTH := 4
	const PAGE_NAME_MAX_CHARACTERS := 21
	
	var item_list: D2ItemList
	var page_name: String
	
	func _init(cursor: BitCursor) -> void:
		cursor.discard_bits(FLAGS_BYTE_OFFSET * 8) # 2
		# Skip flags section
		if cursor._data.decode_u16(cursor._bit_pos>>3) != ItemParser.ITEM_SIGNATURE:
			cursor.discard_bits(FLAGS_BYTE_LENGTH << 3)
		# Page name
		for i: int in PAGE_NAME_MAX_CHARACTERS:
			var char_code: int = cursor.read_bits(8)
			if char_code == 0: # Null terminates
				break
			page_name += char(char_code)
		# Cursor is now at item list
		item_list = D2ItemList.new(cursor)
