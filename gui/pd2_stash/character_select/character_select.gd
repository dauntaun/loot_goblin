class_name CharacterSelectGUI
extends Control

signal character_selected(character_id: int)

const BUTTON_SCENE = preload("uid://tgixuggfwchr")


func _ready() -> void:
	for node: Node in get_children():
		node.queue_free()
	StashRegistry.characters_registered.connect(init_characters)


func init_characters() -> void:
	for node: Node in get_children():
		node.free()
	
	var character_files := StashRegistry.get_character_files()
	var base_button := BUTTON_SCENE.instantiate()
	
	for character_file: D2CharacterSaveFile in character_files:
		var button := base_button.duplicate()
		add_child(button)
		button.init_button(character_file)
		button.pressed.connect(func() -> void: 
			character_selected.emit(character_file.character_id))
	base_button.free()
	
	var first_button := get_child(0) as CharacterSelectButton
	if first_button:
		first_button.button_pressed = true
		first_button.pressed.emit()
