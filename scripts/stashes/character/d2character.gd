class_name D2Character

static var character_id_counter := 0

var character_id: int
var char_item_list: D2ItemList
var merc_item_list: D2ItemList

var character_name: String
var character_class_code: int
var character_class_name: String
var character_level: int
var is_hardcore: bool


func _init() -> void:
	character_id = character_id_counter
	character_id_counter += 1
