class_name SearchBar
extends LineEdit

signal query_submitted(query: String)

@export var focus_search_shortcut: Shortcut
@export var exit_search_shortcut: Shortcut

@onready var _search_timer: Timer = %SearchTimer
@onready var _search_info: RichTextLabel = %SearchInfo


func _ready() -> void:
	text_changed.connect(_start_timer)
	_search_timer.timeout.connect(_emit_query)
	focus_entered.connect(func(): _search_info.hide())
	focus_exited.connect(func(): if text.is_empty():_search_info.show())


func _input(event: InputEvent) -> void:
	if focus_search_shortcut.matches_event(event):
		grab_focus()
		select_all()
		get_viewport().set_input_as_handled()
	elif exit_search_shortcut.matches_event(event) or event.is_action_pressed("enter") or event.is_action_pressed("mouse_left") or event.is_action_pressed("mouse_right"):
		if event.is_action_pressed("enter") and not GlobalSettings.instant_search:
			_emit_query()
		release_focus()
	if has_focus():
		return


func _start_timer(_text: String) -> void:
	if GlobalSettings.instant_search:
		_search_timer.start()


func _emit_query() -> void:
	_search_timer.stop()
	query_submitted.emit(text)
	
