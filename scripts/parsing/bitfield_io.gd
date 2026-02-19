class_name BitFieldIO


static func read_bits(data: PackedByteArray, start_bit: int, length: int) -> int:
	var byte_index: int = start_bit >> 3
	var bit_offset: int = start_bit & 7
	
	# Total bits we need from byte boundary
	var total_bits: int = bit_offset + length
	var bytes_needed: int = (total_bits + 7) >> 3  # ceil / 8
	
	var value: int = 0
	for i: int in bytes_needed:
		var idx: int = byte_index + i
		if idx >= data.size():
			break
		value |= data[idx] << (i << 3)

	value >>= bit_offset
	return value & ((1 << length) - 1)


static func write_bits(data: PackedByteArray, start_bit: int, length: int, value: int) -> void:
	var byte_index: int = start_bit / 8
	var bit_offset: int = start_bit % 8

	var chunk: int = 0
	for i: int in 8:
		var index: int = byte_index + i
		if index < data.size():
			chunk |= data.get(index) << (8 * i)

	var mask: int = ((1 << length) - 1) << bit_offset
	chunk = (chunk & ~mask) | ((value << bit_offset) & mask)

	for i: int in 8:
		var index: int = byte_index + i
		if index < data.size():
			data[index] = (chunk >> (8 * i)) & 0xFF


static func remove_section(data: PackedByteArray, from_byte: int, length: int) -> void:
	var new_data := PackedByteArray()
	new_data.append_array(data.slice(0, from_byte))
	new_data.append_array(data.slice(from_byte + length, data.size()))
	data.clear()
	data.append_array(new_data)
