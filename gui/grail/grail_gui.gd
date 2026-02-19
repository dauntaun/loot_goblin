extends Control

@onready var root: Control = %GrailRoot

var grids: Array[Control] = []


func _ready() -> void:
	_clear_root()
	return
	_build_grids()


func _clear_root() -> void:
	for child in root.get_children():
		child.queue_free()
	grids.clear()


func _build_grids() -> void:
	for item_class: String in TxtDB.valid_uniques.keys():
		_create_class_section(item_class, TxtDB.valid_uniques[item_class])


func _create_class_section(item_class: String, types: Dictionary) -> void:
	var class_fold := FoldableContainer.new()
	class_fold.title = item_class.capitalize()
	root.add_child(class_fold)

	var class_box := VBoxContainer.new()
	class_fold.add_child(class_box)

	for item_type: String in types.keys():
		_create_type_section(class_box, item_class, item_type, types[item_type])


func _create_type_section(
	parent: VBoxContainer,
	item_class: String,
	item_type: String,
	tiers: Dictionary
) -> void:
	var type_fold := FoldableContainer.new()
	type_fold.title = item_type.capitalize()
	parent.add_child(type_fold)

	var type_box := VBoxContainer.new()
	type_fold.add_child(type_box)
	type_fold.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var tier_row := HBoxContainer.new()
	tier_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_box.add_child(tier_row)

	for tier: int in tiers.keys():
		_create_tier_section(
			tier_row,
			item_class,
			item_type,
			tier,
			tiers[tier]
		)


func _create_tier_section(
	parent: HBoxContainer,
	item_class: String,
	item_type: String,
	tier: int,
	items: Array
) -> void:
	var tier_fold := FoldableContainer.new()
	tier_fold.title = D2Item.ItemTier.keys()[tier].capitalize()
	tier_fold.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(tier_fold)

	var tier_container := VBoxContainer.new()
	tier_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tier_container.set_meta("item_class", item_class)
	tier_container.set_meta("item_type", item_type)
	tier_container.set_meta("item_tier", tier)
	tier_fold.add_child(tier_container)

	grids.append(tier_container)

	for row: Dictionary in items:
		var label := Label.new()
		label.text = row.name
		label.set_meta("unique_id", row.id)
		label.add_theme_color_override("font_color", D2Colors.COLOR_GRAY)
		tier_container.add_child(label)


func update_grail() -> void:
	_highlight_collected_uniques()


func _highlight_collected_uniques() -> void:
	return
	_reset_all_grids()

	var collected := {}
	for item: D2Item in %GoblinStash.get_items_by_rarity(D2Item.ItemRarity.UNIQUE):
		collected[item.unique_id] = true

	for tier_container in grids:
		for label: Label in tier_container.get_children():
			if collected.has(label.get_meta("unique_id")):
				label.add_theme_color_override(
					"font_color",
					D2Colors.COLOR_UNIQUE
				)


func _reset_all_grids() -> void:
	for tier_container in grids:
		for label: Label in tier_container.get_children():
			label.add_theme_color_override(
				"font_color",
				D2Colors.COLOR_GRAY
			)
