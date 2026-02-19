class_name D2Item

enum ItemRarity {
	INVALID,
	INFERIOR,
	NORMAL,
	SUPERIOR,
	MAGIC,
	SET,
	RARE,
	UNIQUE,
	CRAFTED,
	TEMPERED}

enum ItemLocation {STORED, EQUIPPED, BELT, GROUND, CURSOR, SOCKETED = 6}
enum StoreLocation {NONE, INVENTORY=1, CUBE=4, STASH=5, PD2_STASH=6}
enum EquipLocation {NONE=0, HEAD=1, NECK=2, TORSO=3, HAND_RIGHT=4, HAND_LEFT=5, FINGER_RIGHT=6,
 	FINGER_LEFT=7, WAIST=8, FEET=9, HANDS=10, ALT_HAND_RIGHT=11, ALT_HAND_LEFT=12}

enum ItemTier {NORMAL, EXCEPTIONAL, ELITE}
enum ClassSpecific {ANY = 99, AMA = 0, SOR = 1, NEC = 2, PAL = 3, BAR = 4, DRU = 5, ASS = 6}

const PLUGY_STORE_LOCATION := StoreLocation.STASH
const PD2_STORE_LOCATION := StoreLocation.PD2_STASH

var item_id: int ## Stable item ID

var code_string: String
var base_name: String
var location_id: ItemLocation
var store_id: StoreLocation
var equipped_id: EquipLocation
var x_coord: int
var y_coord: int
var is_simple: bool
var is_ear: bool
var is_identified: bool
var is_socketed: bool
var is_ethereal: bool
var is_personalized: bool
var has_runeword: bool
var socketed_item_count: int
var socketed_items: Array[D2Item]
var inv_width: int
var inv_height: int

var unique_signature: int
var item_level: int
var rarity: ItemRarity

var has_multiple_pictures: bool
var picture_id: int
var has_automods: bool
var automagic_id: int
var inferior_id: int
var superior_id: int
var magic_prefix_id: int
var magic_suffix_id: int
var set_id: int
var unique_id: int
var first_rare_name_id: int
var second_rare_name_id: int
var rare_prefix_amount: int
var rare_suffix_amount: int
var rare_prefix_ids: Array[int]
var rare_suffix_ids: Array[int]
var rare_prefixes: Array[String]
var rare_suffixes: Array[String]


var is_armor: bool
var is_shield: bool
var is_weapon: bool
var item_type: String
var item_tier: ItemTier
var item_class: ClassSpecific
var is_corrupted: bool
var required_strength: int
var required_dexterity: int
var required_level: int
var is_misc: bool
var is_rune: bool
var is_tome: bool
var is_stackable: bool
var runeword_id: int
var personalized_name: String
var defense: int
var base_defense: int
var base_weapon_damage: Dictionary
var weapon_damage: Dictionary

var max_durability: int
var current_durability: int
var quantity: int
var total_sockets: int
var set_prop_bits: int

var all_properties: Array[Dictionary]
var all_properties_formatted: Array[String]
var magic_properties: Array[Dictionary]
var set_properties: Array[Dictionary]
var runeword_properties: Array[Dictionary]

var search_cache: String

var item_name: String

var start_byte: int
var length: int


func get_runes_string() -> String:
	var runes_string: String = ""
	for socketed_item: D2Item in socketed_items:
		if socketed_item.is_rune:
			runes_string += socketed_item.item_name.split(" ")[0]
	if runes_string != "":
		runes_string = "'" + runes_string + "'"
		return runes_string
	return ""


func build_search_cache() -> void:
	var parts: Array[String]
	parts.append(base_name)
	parts.append(item_type)
	parts.append(item_name)
	parts.append_array(all_properties_formatted)
	if is_ethereal:
		parts.append("ethereal")
	if is_socketed:
		parts.append("socketed (%d)" % total_sockets)
	search_cache = " ".join(parts).to_lower()


func get_coord() -> Vector2i:
	return Vector2i(x_coord, y_coord)


func print_info() -> void:
	print("Code: ", code_string)
	print("Location: ", location_id)
	print("Equipped ID: ", equipped_id)
	print("Coords: (", x_coord, ", ", y_coord, ")")
	print("Panel: ", store_id)
	print("Simple: ", is_simple)
