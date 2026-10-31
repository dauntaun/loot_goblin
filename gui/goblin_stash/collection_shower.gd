extends Button

const COLLECTION_MANAGER_SCENE := preload("uid://bfapiumbw4fmq")

var _collection_popup: PopupPanel
var _collection_manager: CollectionManager

func _ready() -> void:
	toggled.connect(_toggle_collection_manager)
	_collection_popup = PopupPanel.new()
	_collection_manager = COLLECTION_MANAGER_SCENE.instantiate()
	_collection_popup.add_child(_collection_manager)
	add_child(_collection_popup)
	_collection_popup.popup_hide.connect(func(): set_pressed_no_signal(false))


func _toggle_collection_manager(_toggled: bool) -> void:
	_collection_manager.refresh()
	_collection_popup.popup_centered(Vector2i(512, 450))
