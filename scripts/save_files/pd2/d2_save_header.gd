class_name D2SaveHeader

const FILE_SIZE_BYTE_OFFSET: int = 8
const CHECKSUM_BYTE_OFFSET: int = 12
const CHECKSUM_BYTE_LENGTH: int = 4

var _data: PackedByteArray


func _init(data: PackedByteArray) -> void:
	_data = data


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
