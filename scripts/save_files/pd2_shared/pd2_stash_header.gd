class_name PD2Header

const FILE_SIZE_BYTE_OFFSET: int = 8
const CHECKSUM_BYTE_OFFSET: int = 12
const CHECKSUM_BYTE_LENGTH: int = 4

const ITEM_LIST_BYTE_OFFSET: int = 302
const ITEM_COUNT_BYTE_OFFSET: int = 304

var parse_successful: bool
var _data: PackedByteArray


func _init(cursor: BitCursor) -> void:
	_data = cursor._data
	cursor.set_at(ITEM_LIST_BYTE_OFFSET << 3)
	if _data.decode_u16(cursor._bit_pos>>3) != ItemParser.ITEM_SIGNATURE:
		push_error("Invalid PD2 stash header")
		return
	parse_successful = true
	cursor.set_at(ITEM_LIST_BYTE_OFFSET << 3)


func read_item_count() -> int:
	return _data.decode_u16(ITEM_COUNT_BYTE_OFFSET)


func write_item_count(count: int) -> void:
	_data.encode_u16(ITEM_COUNT_BYTE_OFFSET, count)


func update_file_size() -> void:
	_data.encode_u16(FILE_SIZE_BYTE_OFFSET, _data.size())


func write_checksum() -> void:
	if _data.size() < CHECKSUM_BYTE_OFFSET + CHECKSUM_BYTE_LENGTH:
		push_error("File too small to contain a checksum header")
		return

	# zero checksum field
	for i: int in CHECKSUM_BYTE_LENGTH:
		_data[CHECKSUM_BYTE_OFFSET + i] = 0

	var checksum: int = 0
	for i: int in _data.size():
		var byte_val: int = _data[i]
		checksum = ((checksum << 1) | (checksum >> 31)) & 0xFFFFFFFF
		checksum = (checksum + byte_val) & 0xFFFFFFFF

	# write checksum
	for i: int in CHECKSUM_BYTE_LENGTH:
		_data[CHECKSUM_BYTE_OFFSET + i] = (checksum >> (8 * i)) & 0xFF
