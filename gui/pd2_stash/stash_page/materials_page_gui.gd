class_name MaterialsPageGUI # TODO make base class with regular stash pages
extends PanelContainer

var _initialized: bool = false

# Grids
@onready var upper_runes: StashPageGUI = %UpperRunes
@onready var lower_runes: StashPageGUI = %LowerRunes
@onready var organs: StashPageGUI = %Organs
@onready var potions: StashPageGUI = %Potions
@onready var craft_mats: StashPageGUI = %CraftMats
@onready var essences: StashPageGUI = %Essences
@onready var gems: StashPageGUI = %Gems
@onready var map_mats: StashPageGUI = %MapMats
@onready var all_grids: Array[StashPageGUI] = [upper_runes, lower_runes, organs, potions, craft_mats, essences, gems, map_mats]

@onready var materials_place_map: Dictionary[String, Dictionary] = {
	"r01s": {"coord": Vector2i(0, 0), "grid": upper_runes}, #el
	"r02s": {"coord": Vector2i(1, 0), "grid": upper_runes}, #eld
	"r03s": {"coord": Vector2i(2, 0), "grid": upper_runes}, #tir
	"r04s": {"coord": Vector2i(3, 0), "grid": upper_runes}, #nef
	"r05s": {"coord": Vector2i(4, 0), "grid": upper_runes}, #eth
	"r06s": {"coord": Vector2i(5, 0), "grid": upper_runes}, #ith
	"r07s": {"coord": Vector2i(6, 0), "grid": upper_runes}, #tal
	"r08s": {"coord": Vector2i(7, 0), "grid": upper_runes}, #ral
	"r09s": {"coord": Vector2i(8, 0), "grid": upper_runes}, #ort
	"r10s": {"coord": Vector2i(0, 1), "grid": upper_runes}, #thul
	"r11s": {"coord": Vector2i(1, 1), "grid": upper_runes}, #amn
	"r12s": {"coord": Vector2i(2, 1), "grid": upper_runes}, #sol
	"r13s": {"coord": Vector2i(3, 1), "grid": upper_runes}, #shael
	"r14s": {"coord": Vector2i(4, 1), "grid": upper_runes}, #dol
	"r15s": {"coord": Vector2i(5, 1), "grid": upper_runes}, #hel
	"r16s": {"coord": Vector2i(6, 1), "grid": upper_runes}, #io
	"r17s": {"coord": Vector2i(7, 1), "grid": upper_runes}, #lum
	"r18s": {"coord": Vector2i(8, 1), "grid": upper_runes}, #ko
	"r19s": {"coord": Vector2i(0, 2), "grid": upper_runes}, #fal
	"r20s": {"coord": Vector2i(1, 2), "grid": upper_runes}, #lem
	"r21s": {"coord": Vector2i(2, 2), "grid": upper_runes}, #pul
	"r22s": {"coord": Vector2i(3, 2), "grid": upper_runes}, #um
	"r23s": {"coord": Vector2i(4, 2), "grid": upper_runes}, #mal
	"r24s": {"coord": Vector2i(5, 2), "grid": upper_runes}, #ist
	"r25s": {"coord": Vector2i(6, 2), "grid": upper_runes}, #gul
	"r26s": {"coord": Vector2i(7, 2), "grid": upper_runes}, #vex
	"r27s": {"coord": Vector2i(8, 2), "grid": upper_runes}, #ohm
	"r28s": {"coord": Vector2i(0, 0), "grid": lower_runes}, #lo
	"r29s": {"coord": Vector2i(1, 0), "grid": lower_runes}, #sur
	"r30s": {"coord": Vector2i(2, 0), "grid": lower_runes}, #ber
	"r31s": {"coord": Vector2i(3, 0), "grid": lower_runes}, #jah
	"r32s": {"coord": Vector2i(4, 0), "grid": lower_runes}, #cham
	"r33s": {"coord": Vector2i(5, 0), "grid": lower_runes}, #zod
	"glys": {"coord": Vector2i(0, 4), "grid": gems}, #flawless topaz
	"glws": {"coord": Vector2i(0, 5), "grid": gems}, #flawless diamond
	"gzvs": {"coord": Vector2i(0, 1), "grid": gems}, #flawless amethyst
	"glbs": {"coord": Vector2i(0, 2), "grid": gems}, #flawless sapphire
	"glgs": {"coord": Vector2i(0, 3), "grid": gems}, #flawless emerald
	"glrs": {"coord": Vector2i(0, 0), "grid": gems}, #flawless ruby
	"skls": {"coord": Vector2i(0, 6), "grid": gems}, #flawless skull
	"gpys": {"coord": Vector2i(1, 4), "grid": gems}, #perfect topaz
	"gpws": {"coord": Vector2i(1, 5), "grid": gems}, #perfect diamond
	"gpvs": {"coord": Vector2i(1, 1), "grid": gems}, #perfect amethyst
	"gpbs": {"coord": Vector2i(1, 2), "grid": gems}, #perfect sapphire
	"gpgs": {"coord": Vector2i(1, 3), "grid": gems}, #pefect emerald
	"gprs": {"coord": Vector2i(1, 0), "grid": gems}, #perfect ruby
	"skzs": {"coord": Vector2i(1, 6), "grid": gems}, #perect skull
	"crfu": {"coord": Vector2i(2, 4), "grid": gems}, #bounty craft
	"crfp": {"coord": Vector2i(2, 5), "grid": gems}, #brilliant craft
	"crfc": {"coord": Vector2i(2, 1), "grid": gems}, #caster craft
	"crfh": {"coord": Vector2i(2, 2), "grid": gems}, #hitpower craft
	"crfs": {"coord": Vector2i(2, 3), "grid": gems}, #safety craft
	"crfb": {"coord": Vector2i(2, 0), "grid": gems}, #blood craft
	"crfv": {"coord": Vector2i(2, 6), "grid": gems}, #vampiric craft
	"pk1": {"coord": Vector2i(0, 0), "grid": organs}, #key1
	"pk2": {"coord": Vector2i(1, 0), "grid": organs}, #key2
	"pk3": {"coord": Vector2i(2, 0), "grid": organs}, #key3
	"mbr": {"coord": Vector2i(0, 2), "grid": organs}, #brain
	"bey": {"coord": Vector2i(1, 2), "grid": organs}, #eye
	"dhn": {"coord": Vector2i(2, 2), "grid": organs}, #horn
	"ubaa": {"coord": Vector2i(0, 3), "grid": organs}, #T1 sigil
	"ubab": {"coord": Vector2i(1, 3), "grid": organs}, #T2 sigil
	"ubac": {"coord": Vector2i(2, 3), "grid": organs}, #T3 sigil
	"dcbl": {"coord": Vector2i(0, 4), "grid": organs}, #PDE
	"dcso": {"coord": Vector2i(1, 4), "grid": organs}, #PES
	"dcho": {"coord": Vector2i(2, 4), "grid": organs}, #black soulstone
	"rtmo": {"coord": Vector2i(0, 5), "grid": organs}, #jawbone
	"rtmv": {"coord": Vector2i(1, 5), "grid": organs}, #splinter
	"cm2f": {"coord": Vector2i(2, 5), "grid": organs}, #hellfire ash
	"lucb": {"coord": Vector2i(0, 6), "grid": organs}, #demonic insignia
	"lucc": {"coord": Vector2i(1, 6), "grid": organs}, #talisman of transgression
	"lucd": {"coord": Vector2i(2, 6), "grid": organs}, #flesh of malic
	"rvs": {"coord": Vector2i(0, 0), "grid": potions}, #rejuv
	"rvl": {"coord": Vector2i(1, 0), "grid": potions}, #full rejuv
	"imrn": {"coord": Vector2i(0, 0), "grid": craft_mats}, #demonic cube
	"jewf": {"coord": Vector2i(1, 0), "grid": craft_mats}, #jewel fragments
	"cwss": {"coord": Vector2i(0, 1), "grid": craft_mats}, #twss
	"wss": {"coord": Vector2i(1, 1), "grid": craft_mats}, #wss
	"lbox": {"coord": Vector2i(0, 2), "grid": craft_mats}, #pbox
	"lpp": {"coord": Vector2i(1, 2), "grid": craft_mats}, #ppiece
	"tes": {"coord": Vector2i(0, 0), "grid": essences}, #blue
	"ceh": {"coord": Vector2i(1, 0), "grid": essences}, #yellow
	"bet": {"coord": Vector2i(0, 1), "grid": essences}, #red
	"fed": {"coord": Vector2i(1, 1), "grid": essences}, #green
	"std": {"coord": Vector2i(0, 0), "grid": map_mats}, #standard
	"iwss": {"coord": Vector2i(1, 0), "grid": map_mats}, #catalyst
	"upmp": {"coord": Vector2i(2, 0), "grid": map_mats}, #cartographer
	"irma": {"coord": Vector2i(3, 0), "grid": map_mats}, #infused arcane
	"urma": {"coord": Vector2i(4, 0), "grid": map_mats}, #infused angelic
	"irra": {"coord": Vector2i(5, 0), "grid": map_mats}, #infused zakarum
	"rrra": {"coord": Vector2i(6, 0), "grid": map_mats}, #infused horadric
	"scrb": {"coord": Vector2i(0, 1), "grid": map_mats}, #scarab
	"fort": {"coord": Vector2i(1, 1), "grid": map_mats}, #fortify
	"scou": {"coord": Vector2i(2, 1), "grid": map_mats}, #destruction
	"imma": {"coord": Vector2i(3, 1), "grid": map_mats}, #arcane
	"upma": {"coord": Vector2i(4, 1), "grid": map_mats}, #angelic
	"imra": {"coord": Vector2i(5, 1), "grid": map_mats}, #zakarum
	"rera": {"coord": Vector2i(6, 1), "grid": map_mats}, #horadric
}


func _ready() -> void:
	for grid: StashPageGUI in all_grids:
		grid.item_selected.connect(_on_item_selected)


func init_materials(materials_page: MaterialsPage) -> void:
	if _initialized:
		reset()
	var items := materials_page.get_materials()
	for item: D2Item in items:
		var place_parameters: Dictionary = materials_place_map[item.code_string]
		item.x_coord = place_parameters["coord"].x
		item.y_coord = place_parameters["coord"].y
		place_parameters["grid"].add_item_rect(item)
	_initialized = true


func reset() -> void:
	for grid: StashPageGUI in all_grids:
		grid._reset()


func _on_item_selected(_item: D2Item) -> void:
	pass
