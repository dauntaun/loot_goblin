@abstract class_name BasicSaveFile

var data: PackedByteArray
var load_path: String
var load_timestamp: int
var save_timestamp: int
var load_successful: bool


func _init(path: String = "") -> void:
	data = FileAccess.get_file_as_bytes(path)
	load_timestamp = FileAccess.get_access_time(path)
	save_timestamp = FileAccess.get_modified_time(path)
	load_path = path
	load_file()


func file_has_changed_since_load() -> bool:
	return FileAccess.get_modified_time(load_path) != save_timestamp or \
		FileAccess.get_access_time(load_path) != load_timestamp


@abstract func load_file() -> void
@abstract func save_file(path: String) -> void
