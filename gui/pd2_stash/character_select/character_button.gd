class_name CharacterSelectButton
extends Button

@onready var name_label: Label = %NameLabel
@onready var description: Label = %Description


func init_button(character: D2CharacterSaveFile) -> void:
	name_label.text = character.character_name
	if character.is_hardcore:
		name_label.add_theme_color_override("font_color", D2Colors.COLOR_CORRUPTED)
	description.text = "Level %d %s" % [character.character_level, character.character_class_name]
