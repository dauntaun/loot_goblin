class_name ItemRect
extends Control

signal item_selected(item: D2Item)


@onready var quantity_label: Label = %QuantityLabel
@onready var background_texture: TextureRect = %BackgroundTexture
@onready var item_texture: TextureRect = %ItemTexture
@onready var highlight_rect: ColorRect = %HighlightColor

var _item: D2Item


func _ready() -> void:
	mouse_entered.connect(_show_tooltip)
	mouse_exited.connect(_hide_tooltip)


func init_rect(item: D2Item) -> void:
	z_index = 1
	_item = item
	if item.is_stackable and item.is_misc and item.item_type not in ["Bolts", "Arrows"]:
		quantity_label.text = str(item.quantity) + " "
		quantity_label.show()
	else:
		quantity_label.hide()
	item_texture.texture = TxtDB.get_item_invfile(item)
	if item.is_ethereal:
		item_texture.modulate.a = 0.5


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			item_selected.emit(_item)


func highlight() -> void:
	highlight_rect.show()


func remove_highlight() -> void:
	highlight_rect.hide()


func hide_background_texture() -> void:
	background_texture.hide()


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
