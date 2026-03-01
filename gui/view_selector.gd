extends Control

enum Selection {GOBLIN, PD2, GRAIL}

var current_selection: Selection

@onready var goblin_view_button: Button = %GoblinView
@onready var pd2_view_button: Button = %PD2View
@onready var grail_view_button: Button = %GrailView

@onready var view_tab: TabContainer = %ViewSelector
@onready var main_tab: TabContainer = %MainSelector

@onready var search_box: HBoxContainer = %SearchBox

@onready var selection_map: Dictionary[Selection, Dictionary] = {
	Selection.GOBLIN: {"button": goblin_view_button, "main_tab": 0, "view_tab": 0},
	Selection.PD2: {"button": pd2_view_button, "main_tab": 0, "view_tab": 1},
	Selection.GRAIL: {"button": grail_view_button, "main_tab": 1},
}


func _ready() -> void:
	selection_map[Selection.GOBLIN].button.button_pressed = true
	_change_view(Selection.GOBLIN)
	
	goblin_view_button.pressed.connect(_change_view.bind(Selection.GOBLIN))
	pd2_view_button.pressed.connect(_change_view.bind(Selection.PD2))
	grail_view_button.pressed.connect(_change_view.bind(Selection.GRAIL))
	view_tab.tab_changed.connect(_reset_selection)


func _change_view(selection: Selection) -> void:
	main_tab.current_tab = selection_map[selection].main_tab
	view_tab.current_tab = selection_map[selection].get("view_tab", 0)
	search_box.visible = selection == Selection.GOBLIN


func _reset_selection(tab: int) -> void:
	ItemSelection.clear_selection()
	var current_view := view_tab.get_child(tab)
	if current_view.has_method("restore_last_selection"):
		current_view.restore_last_selection()
