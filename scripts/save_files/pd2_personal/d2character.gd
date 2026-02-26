class_name D2CharacterSaveFile
extends BasicSaveFile

const CHARACTER_SIGNATURE := 0xaa55aa55
const SKILLS_SIGNATURE := 0x6669 # if
const MERC_SIGNATURE := 0x666a # jf
const NAME_BYTE_OFFSET := 20
const NAME_BYTE_LENGTH := 16
const STATUS_FLAGS_BYTE_OFFSET := 36
const HARDCORE_STATUS_BIT := 1 << 2
const CLASS_BYTE_OFFSET := 40
const LEVEL_BYTE_OFFSET := 43
const ATTRIBUTES_BYTE_OFFSET := 765

const CLASS_NAMES: Dictionary[int, String] = {
	0 : "Amazon",
	1 : "Sorceress",
	2 : "Necromancer",
	3 : "Paladin",
	4 : "Barbarian",
	5 : "Druid",
	6 : "Assassin",
}

const ATRRIBUTE_MAP: Dictionary[int, Dictionary] = {
	0: {"attribute": "Strength", "bit_length": 10},
	1: {"attribute": "Energy", "bit_length": 10},
	2: {"attribute": "Dexterity", "bit_length": 10},
	3: {"attribute": "Vitality", "bit_length": 10},
	4: {"attribute": "Unused stats", "bit_length": 10},
	5: {"attribute": "Unused skills", "bit_length": 8},
	6: {"attribute": "Current HP", "bit_length": 21},
	7: {"attribute": "Max HP", "bit_length": 21},
	8: {"attribute": "Current mana", "bit_length": 21},
	9: {"attribute": "Max mana", "bit_length": 21},
	10: {"attribute": "Current stamina", "bit_length": 21},
	11: {"attribute": "Max stamina", "bit_length": 21},
	12: {"attribute": "Level", "bit_length": 7},
	13: {"attribute": "Experience", "bit_length": 32},
	14: {"attribute": "Gold", "bit_length": 25},
	15: {"attribute": "Stashed gold", "bit_length": 25},
}

var item_list: D2ItemList
var merc_item_list: D2ItemList

var character_name: String
var character_class_code: int
var character_class_name: String
var character_level: int
var is_hardcore: bool


func load_file() -> void:
	if data.decode_u32(0) != CHARACTER_SIGNATURE:
		push_error("Unknown character file signature")
		return
	load_successful = true
		
	for i: int in NAME_BYTE_LENGTH:
		var char_code := data.decode_u8(NAME_BYTE_OFFSET + i)
		if char_code == 0:
			break
		character_name += char(char_code)
	
	is_hardcore = data.decode_u8(STATUS_FLAGS_BYTE_OFFSET) & HARDCORE_STATUS_BIT
	character_class_code = data.decode_u8(CLASS_BYTE_OFFSET)
	character_class_name = CLASS_NAMES[character_class_code]
	character_level = data.decode_u8(LEVEL_BYTE_OFFSET)
	read_item_lists()


func save_file(_path: String) -> void:
	return


func read_item_lists() -> void:
	var cursor := BitCursor.new(data, ATTRIBUTES_BYTE_OFFSET << 3)
	# Skip identifier "gf"
	cursor.discard_bits(2 << 3)
	# Parse attributes
	# 1. read 9 bits id. (reverse them)
	# 2. if the id is 0x1ff, terminate the loop
	# 3. read bit length from attribute map for that id.
	# 4. read bit length nr of bits. 
	while true:
		var attribute_id := cursor.read_bits(9)
		#var attribute_id := cursor.read_bits_reversed(9)
		if attribute_id == 0x1ff:
			break
		var value := cursor.read_bits(ATRRIBUTE_MAP[attribute_id].bit_length)
	cursor.discard_to_byte_boundary()
	# Skip skill section
	if not data.decode_u16(cursor._bit_pos>>3) == SKILLS_SIGNATURE:
		push_error("Unknown skills signature")
		return
	cursor.discard_bits(32 << 3)
	# Cursor is now at item list
	cursor.discard_bits(3 << 3) # No idea why we have to discard 3 bytes
	item_list = D2ItemList.new(cursor)
	# Cursor is now at corpse item list
	if character_name == "Lucky":
		pass
	var corpse_items := D2ItemList.new(cursor)
	if corpse_items._parsed_item_count == 1:
		cursor.discard_bits(12 << 3)
		var real_corpse_items := D2ItemList.new(cursor)
		item_list = real_corpse_items
	# Cursor is now at merc items
	if not data.decode_u16(cursor._bit_pos>>3) == MERC_SIGNATURE:
		push_error("Unknown merc signature")
		return
	cursor.discard_bits(2 << 3)
	merc_item_list = D2ItemList.new(cursor)
