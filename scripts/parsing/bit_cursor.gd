class_name BitCursor

var _data: PackedByteArray
var _bit_pos: int
var _data_size: int


func _init(data: PackedByteArray, start_from: int = 0) -> void:
	_data = data
	_bit_pos = start_from
	_data_size = _data.size()


func read_bits(length: int) -> int: # Inline BitfieldIO.read_bits
	var next_pos := _bit_pos + length
	if ((_bit_pos + length + 7) >> 3) > _data_size:
		push_error("BitCursor overflow")
		return -1

	var byte_index := _bit_pos >> 3
	var bit_offset := _bit_pos & 7

	var total_bits := bit_offset + length
	var bytes_needed := (total_bits + 7) >> 3

	var value := 0
	for i in bytes_needed:
		value |= _data[byte_index + i] << (i << 3)

	value >>= bit_offset
	_bit_pos = next_pos
	return value & ((1 << length) - 1)


func jump_and_read(discard_length: int, read_length: int) -> int:
	_bit_pos += discard_length
	return read_bits(read_length)


func discard_bits(length: int) -> void:
	_bit_pos += length


func can_read(length: int) -> bool:
	return ((_bit_pos + length + 7) >> 3) <= _data_size


func discard_to_byte_boundary() -> void:
	var misalignment: int = _bit_pos & 7
	if misalignment != 0:
		_bit_pos += 8 - misalignment


func set_at(bit: int) -> void:
	_bit_pos = bit
