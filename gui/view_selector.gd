extends Control

enum Selection {GOBLIN, PD2, GRAIL}

var current_selection: Selection

@onready var goblin_view: Button = %GoblinView
@onready var pd2_view: Button = %PD2View
@onready var grail_view: Button = %GrailView

@onready var view_tabs: TabContainer = %ViewSelector
@onready var search_bar: SearchBar = %SearchBar

@onready var selection_map: Dictionary[Selection, Button] = {
	Selection.GOBLIN : goblin_view,
	Selection.PD2 : pd2_view,
	Selection.GRAIL : grail_view,
}


func _ready() -> void:
	selection_map[view_tabs.current_tab].button_pressed = true
	
	goblin_view.pressed.connect(_change_view.bind(Selection.GOBLIN))
	pd2_view.pressed.connect(_change_view.bind(Selection.PD2))
	grail_view.pressed.connect(_change_view.bind(Selection.GRAIL))
	view_tabs.tab_changed.connect(_reset_selection)


func _change_view(selection: Selection) -> void:
	view_tabs.current_tab = selection
	search_bar.visible = selection == Selection.GOBLIN


func _reset_selection(tab: int) -> void:
	ItemSelection.clear_selection()
	var current_view := view_tabs.get_child(tab)
	if current_view.has_method("restore_last_selection"):
		current_view.restore_last_selection()
