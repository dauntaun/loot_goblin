class_name ItemWriter

enum WriteableField {X_COORD, Y_COORD, EQUIPPED_ID, STORE_ID}

const _FIELD_SPEC: Dictionary[WriteableField, Dictionary] = {
	WriteableField.EQUIPPED_ID : {"start_bit": 61, "length": 4},
	WriteableField.X_COORD : {"start_bit": 65, "length": 4},
	WriteableField.Y_COORD : {"start_bit": 69, "length": 4},
	WriteableField.STORE_ID : {"start_bit": 73, "length": 3},
}


static func write_field(data: PackedByteArray, item_start_byte: int, field: WriteableField, value: int) -> void:
	var field_spec: Dictionary = _FIELD_SPEC[field]
	var bit_offset: int = item_start_byte * 8 + field_spec.start_bit
	BitFieldIO.write_bits(data, bit_offset, field_spec.length, value)
