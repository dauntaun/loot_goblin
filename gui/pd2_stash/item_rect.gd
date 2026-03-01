class_name ItemRect
extends Control

signal item_selected(item: D2Item)

#const DEFAULT_MODULATE: Color = Color("ffffffa7")
#const HIGHLIGHT_MODULATE: Color = Color("000000ff")

@onready var quantity_label: Label = %QuantityLabel
@onready var texture_rect: TextureRect = %TextureRect
@onready var highlight_rect: ColorRect = $MarginContainer/Highlight

#var _color: Color = DEFAULT_MODULATE
var _item: D2Item


func _ready() -> void:
	#texture_rect.modulate = _color
	mouse_entered.connect(_show_tooltip)
	mouse_exited.connect(_hide_tooltip)


func init_rect(item: D2Item) -> void:
	z_index = 1
	var color: Color = D2Colors.get_item_color(item)
	color.a = 0.9
	set_color(color)
	_item = item
	if item.is_stackable and item.is_misc and item.item_type not in ["Bow Quiver", "Crossbow Quiver"]:
		quantity_label.text = str(item.quantity) + " "
		quantity_label.show()
	else:
		quantity_label.hide()


func set_color(color: Color) -> void:
	#_color = color
	texture_rect.modulate = color


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			item_selected.emit(_item)


func highlight() -> void:
	highlight_rect.show()
	#texture_rect.modulate = HIGHLIGHT_MODULATE


func remove_highlight() -> void:
	highlight_rect.hide()
	#texture_rect.modulate = _color


func _show_tooltip() -> void:
	if GlobalSettings.show_pd2_tooltips:
		TooltipHandler.show_tooltip_above_target(_item, self)


func _hide_tooltip() -> void:
	TooltipHandler.hide_tooltip()


func select() -> void:
	highlight()
	if not ItemSelection.selection_changed.is_connected(_on_item_selection_changed):
		ItemSelection.selection_changed.connect(_on_item_selection_changed, CONNECT_ONE_SHOT)


func _on_item_selection_changed() -> void:
	remove_highlight()


func _exit_tree() -> void:
	if ItemSelection.get_last_selected_item() == _item:
		ItemSelection.clear_selection()
