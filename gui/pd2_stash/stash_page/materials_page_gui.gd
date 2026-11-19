class_name MaterialsPageGUI # TODO make base class with regular stash pages
extends Control

var _initialized: bool = false

# Grids
@onready var gems: MaterialStashPageGUI = %GemsPage
@onready var runes: MaterialStashPageGUI = %RunesPage
@onready var misc: MaterialStashPageGUI = %MiscPage
@onready var maps: MaterialStashPageGUI = %MapsPage
@onready var ubers: MaterialStashPageGUI = %UbersPage
@onready var all_pages: Array[MaterialStashPageGUI] = [gems, runes, misc, maps, ubers]

@onready var materials_place_map: Dictionary[String, Dictionary] = {
	"r01": {"coord": Vector2i(0, 0), "page": runes, "grid": 0}, #el
	"r02": {"coord": Vector2i(1, 0), "page": runes, "grid": 0}, #eld
	"r03": {"coord": Vector2i(2, 0), "page": runes, "grid": 0}, #tir
	"r04": {"coord": Vector2i(3, 0), "page": runes, "grid": 0}, #nef
	"r05": {"coord": Vector2i(4, 0), "page": runes, "grid": 0}, #eth
	"r06": {"coord": Vector2i(5, 0), "page": runes, "grid": 0}, #ith
	"r07": {"coord": Vector2i(6, 0), "page": runes, "grid": 0}, #tal
	"r08": {"coord": Vector2i(7, 0), "page": runes, "grid": 0}, #ral
	"r09": {"coord": Vector2i(8, 0), "page": runes, "grid": 0}, #ort
	"r10": {"coord": Vector2i(0, 1), "page": runes, "grid": 0}, #thul
	"r11": {"coord": Vector2i(1, 1), "page": runes, "grid": 0}, #amn
	"r12": {"coord": Vector2i(2, 1), "page": runes, "grid": 0}, #sol
	"r13": {"coord": Vector2i(3, 1), "page": runes, "grid": 0}, #shael
	"r14": {"coord": Vector2i(4, 1), "page": runes, "grid": 0}, #dol
	"r15": {"coord": Vector2i(5, 1), "page": runes, "grid": 0}, #hel
	"r16": {"coord": Vector2i(6, 1), "page": runes, "grid": 0}, #io
	"r17": {"coord": Vector2i(7, 1), "page": runes, "grid": 0}, #lum
	"r18": {"coord": Vector2i(8, 1), "page": runes, "grid": 0}, #ko
	"r19": {"coord": Vector2i(0, 2), "page": runes, "grid": 0}, #fal
	"r20": {"coord": Vector2i(1, 2), "page": runes, "grid": 0}, #lem
	"r21": {"coord": Vector2i(2, 2), "page": runes, "grid": 0}, #pul
	"r22": {"coord": Vector2i(3, 2), "page": runes, "grid": 0}, #um
	"r23": {"coord": Vector2i(4, 2), "page": runes, "grid": 0}, #mal
	"r24": {"coord": Vector2i(5, 2), "page": runes, "grid": 0}, #ist
	"r25": {"coord": Vector2i(6, 2), "page": runes, "grid": 0}, #gul
	"r26": {"coord": Vector2i(7, 2), "page": runes, "grid": 0}, #vex
	"r27": {"coord": Vector2i(8, 2), "page": runes, "grid": 0}, #ohm
	"r28": {"coord": Vector2i(0, 0), "page": runes, "grid": 1}, #lo
	"r29": {"coord": Vector2i(1, 0), "page": runes, "grid": 1}, #sur
	"r30": {"coord": Vector2i(2, 0), "page": runes, "grid": 1}, #ber
	"r31": {"coord": Vector2i(3, 0), "page": runes, "grid": 1}, #jah
	"r32": {"coord": Vector2i(4, 0), "page": runes, "grid": 1}, #cham
	"r33": {"coord": Vector2i(5, 0), "page": runes, "grid": 1}, #zod
	"gcr": {"coord": Vector2i(0, 0), "page": gems, "grid": 0}, #chipped ruby
	"gcv": {"coord": Vector2i(1, 0), "page": gems, "grid": 0}, #chipped amethyst
	"gcb": {"coord": Vector2i(2, 0), "page": gems, "grid": 0}, #chipped sapphire
	"gcg": {"coord": Vector2i(3, 0), "page": gems, "grid": 0}, #chipped emerald
	"gcy": {"coord": Vector2i(4, 0), "page": gems, "grid": 0}, #chipped topaz
	"gcw": {"coord": Vector2i(5, 0), "page": gems, "grid": 0}, #chipped diamond
	"skc": {"coord": Vector2i(6, 0), "page": gems, "grid": 0}, #chipped skull
	"gfr": {"coord": Vector2i(0, 1), "page": gems, "grid": 0}, #flawed ruby
	"gfv": {"coord": Vector2i(1, 1), "page": gems, "grid": 0}, #flawed amethyst
	"gfb": {"coord": Vector2i(2, 1), "page": gems, "grid": 0}, #flawed sapphire
	"gfg": {"coord": Vector2i(3, 1), "page": gems, "grid": 0}, #flawed emerald
	"gfy": {"coord": Vector2i(4, 1), "page": gems, "grid": 0}, #flawed topaz
	"gfw": {"coord": Vector2i(5, 1), "page": gems, "grid": 0}, #flawed diamond
	"skf": {"coord": Vector2i(6, 1), "page": gems, "grid": 0}, #flawed skull
	"gsr": {"coord": Vector2i(0, 2), "page": gems, "grid": 0}, #ruby
	"gsv": {"coord": Vector2i(1, 2), "page": gems, "grid": 0}, #amethyst
	"gsb": {"coord": Vector2i(2, 2), "page": gems, "grid": 0}, #sapphire
	"gsg": {"coord": Vector2i(3, 2), "page": gems, "grid": 0}, #emerald
	"gsy": {"coord": Vector2i(4, 2), "page": gems, "grid": 0}, #topaz
	"gsw": {"coord": Vector2i(5, 2), "page": gems, "grid": 0}, #diamond
	"sku": {"coord": Vector2i(6, 2), "page": gems, "grid": 0}, #skull
	"glr": {"coord": Vector2i(0, 3), "page": gems, "grid": 0}, #flawless ruby
	"gzv": {"coord": Vector2i(1, 3), "page": gems, "grid": 0}, #flawless amethyst
	"glb": {"coord": Vector2i(2, 3), "page": gems, "grid": 0}, #flawless sapphire
	"glg": {"coord": Vector2i(3, 3), "page": gems, "grid": 0}, #flawless emerald
	"gly": {"coord": Vector2i(4, 3), "page": gems, "grid": 0}, #flawless topaz
	"glw": {"coord": Vector2i(5, 3), "page": gems, "grid": 0}, #flawless diamond
	"skl": {"coord": Vector2i(6, 3), "page": gems, "grid": 0}, #flawless skull
	"gpr": {"coord": Vector2i(0, 4), "page": gems, "grid": 0}, #perfect ruby
	"gpv": {"coord": Vector2i(1, 4), "page": gems, "grid": 0}, #perfect amethyst
	"gpb": {"coord": Vector2i(2, 4), "page": gems, "grid": 0}, #perfect sapphire
	"gpg": {"coord": Vector2i(3, 4), "page": gems, "grid": 0}, #pefect emerald
	"gpy": {"coord": Vector2i(4, 4), "page": gems, "grid": 0}, #perfect topaz
	"gpw": {"coord": Vector2i(5, 4), "page": gems, "grid": 0}, #perfect diamond
	"skz": {"coord": Vector2i(6, 4), "page": gems, "grid": 0}, #perect skull
	"crfb": {"coord": Vector2i(0, 5), "page": gems, "grid": 0}, #blood craft
	"crfc": {"coord": Vector2i(1, 5), "page": gems, "grid": 0}, #caster craft
	"crfh": {"coord": Vector2i(2, 5), "page": gems, "grid": 0}, #hitpower craft
	"crfs": {"coord": Vector2i(3, 5), "page": gems, "grid": 0}, #safety craft
	"crfu": {"coord": Vector2i(4, 5), "page": gems, "grid": 0}, #bounty craft
	"crfp": {"coord": Vector2i(5, 5), "page": gems, "grid": 0}, #brilliant craft
	"crfv": {"coord": Vector2i(6, 5), "page": gems, "grid": 0}, #vampiric craft
	"jewf": {"coord": Vector2i(0, 0), "page": misc, "grid": 0}, #jewel fragments
	"wss": {"coord": Vector2i(0, 1), "page": misc, "grid": 0}, #wss
	"lpp": {"coord": Vector2i(1, 0), "page": misc, "grid": 0}, #ppiece
	"lbox": {"coord": Vector2i(1, 1), "page": misc, "grid": 0}, #pbox
	"imrn": {"coord": Vector2i(2, 0), "page": misc, "grid": 0}, #demonic cube
	"cwss": {"coord": Vector2i(2, 1), "page": misc, "grid": 0}, #twss
	"lsvl": {"coord": Vector2i(3, 0), "page": misc, "grid": 0}, #vial
	"llmr": {"coord": Vector2i(4, 0), "page": misc, "grid": 0}, #mirror
	"tes": {"coord": Vector2i(0, 0), "page": misc, "grid": 1}, #blue
	"ceh": {"coord": Vector2i(1, 0), "page": misc, "grid": 1}, #yellow
	"bet": {"coord": Vector2i(2, 0), "page": misc, "grid": 1}, #red
	"fed": {"coord": Vector2i(3, 0), "page": misc, "grid": 1}, #green
	"toa": {"coord": Vector2i(4, 0), "page": misc, "grid": 1}, #token
	"rvs": {"coord": Vector2i(0, 0), "page": misc, "grid": 2}, #rejuv
	"rvl": {"coord": Vector2i(1, 0), "page": misc, "grid": 2}, #full rejuv
	"pk1": {"coord": Vector2i(0, 0), "page": ubers, "grid": 0}, #key1
	"pk2": {"coord": Vector2i(1, 0), "page": ubers, "grid": 0}, #key2
	"pk3": {"coord": Vector2i(2, 0), "page": ubers, "grid": 0}, #key3
	"mbr": {"coord": Vector2i(0, 2), "page": ubers, "grid": 0}, #brain
	"bey": {"coord": Vector2i(1, 2), "page": ubers, "grid": 0}, #eye
	"dhn": {"coord": Vector2i(2, 2), "page": ubers, "grid": 0}, #horn
	"ubtm": {"coord": Vector2i(0, 0), "page": ubers, "grid": 1}, #pandemonium
	"ubaa": {"coord": Vector2i(0, 0), "page": ubers, "grid": 2}, #T1 sigil
	"ubab": {"coord": Vector2i(0, 1), "page": ubers, "grid": 2}, #T2 sigil
	"ubac": {"coord": Vector2i(0, 2), "page": ubers, "grid": 2}, #T3 sigil
	"uba": {"coord": Vector2i(0, 3), "page": ubers, "grid": 2}, #ancients
	"dcbl": {"coord": Vector2i(1, 0), "page": ubers, "grid": 2}, #PDE
	"dcso": {"coord": Vector2i(1, 1), "page": ubers, "grid": 2}, #PES
	"dcho": {"coord": Vector2i(1, 2), "page": ubers, "grid": 2}, #black soulstone
	"dcma": {"coord": Vector2i(1, 3), "page": ubers, "grid": 2}, #vision of terror
	"rtmo": {"coord": Vector2i(2, 0), "page": ubers, "grid": 2}, #jawbone
	"rtmv": {"coord": Vector2i(2, 1), "page": ubers, "grid": 2}, #splinter
	"cm2f": {"coord": Vector2i(2, 2), "page": ubers, "grid": 2}, #hellfire ash
	"rtma": {"coord": Vector2i(2, 3), "page": ubers, "grid": 2}, #voidstone
	"lucb": {"coord": Vector2i(3, 0), "page": ubers, "grid": 2}, #demonic insignia
	"lucd": {"coord": Vector2i(3, 1), "page": ubers, "grid": 2}, #flesh of malic
	"lucc": {"coord": Vector2i(3, 2), "page": ubers, "grid": 2}, #talisman of transgression
	"luca": {"coord": Vector2i(3, 3), "page": ubers, "grid": 2}, #shadow of hatred
	"std": {"coord": Vector2i(0, 0), "page": maps, "grid": 3}, #standard
	"iwss": {"coord": Vector2i(1, 0), "page": maps, "grid": 3}, #catalyst
	"upmp": {"coord": Vector2i(2, 0), "page": maps, "grid": 3}, #cartographer
	"irma": {"coord": Vector2i(3, 0), "page": maps, "grid": 3}, #infused arcane
	"urma": {"coord": Vector2i(4, 0), "page": maps, "grid": 3}, #infused angelic
	"irra": {"coord": Vector2i(5, 0), "page": maps, "grid": 3}, #infused zakarum
	"rrra": {"coord": Vector2i(6, 0), "page": maps, "grid": 3}, #infused horadric
	"scrb": {"coord": Vector2i(0, 1), "page": maps, "grid": 3}, #scarab
	"fort": {"coord": Vector2i(1, 1), "page": maps, "grid": 3}, #fortify
	"scou": {"coord": Vector2i(2, 1), "page": maps, "grid": 3}, #destruction
	"imma": {"coord": Vector2i(3, 1), "page": maps, "grid": 3}, #arcane
	"upma": {"coord": Vector2i(4, 1), "page": maps, "grid": 3}, #angelic
	"imra": {"coord": Vector2i(5, 1), "page": maps, "grid": 3}, #zakarum
	"rera": {"coord": Vector2i(6, 1), "page": maps, "grid": 3}, #horadric
	"ivea": {"coord": Vector2i(0, 2), "page": maps, "grid": 3}, #ass ear
	"ivez": {"coord": Vector2i(1, 2), "page": maps, "grid": 3}, #ama ear
	"iveb": {"coord": Vector2i(2, 2), "page": maps, "grid": 3}, #bar ear
	"ived": {"coord": Vector2i(3, 2), "page": maps, "grid": 3}, #dru ear
	"iven": {"coord": Vector2i(4, 2), "page": maps, "grid": 3}, #nec ear
	"ivep": {"coord": Vector2i(5, 2), "page": maps, "grid": 3}, #pal ear
	"ives": {"coord": Vector2i(6, 2), "page": maps, "grid": 3}, #sor ear
	"t11": {"coord": Vector2i(0, 0), "page": maps, "grid": 0}, #viz-jun
	"t21": {"coord": Vector2i(1, 0), "page": maps, "grid": 0}, #phlegethon
	"t22": {"coord": Vector2i(2, 0), "page": maps, "grid": 0}, #torajan jungle
	"t24": {"coord": Vector2i(3, 0), "page": maps, "grid": 0}, #tomb of zoltan
	"t33": {"coord": Vector2i(4, 0), "page": maps, "grid": 0}, #lost temple
	"t34": {"coord": Vector2i(5, 0), "page": maps, "grid": 0}, #ancestral trial
	"t36": {"coord": Vector2i(6, 0), "page": maps, "grid": 0}, #fall of caldeum
	"t26": {"coord": Vector2i(7, 0), "page": maps, "grid": 0}, #shadows of westmarch
	"t14": {"coord": Vector2i(8, 0), "page": maps, "grid": 0}, #sanatorium
	"t18": {"coord": Vector2i(0, 1), "page": maps, "grid": 0}, #poisoned well
	"t12": {"coord": Vector2i(0, 0), "page": maps, "grid": 1}, #horazon memory
	"t25": {"coord": Vector2i(1, 0), "page": maps, "grid": 1}, #sewers
	"t32": {"coord": Vector2i(2, 0), "page": maps, "grid": 1}, #throne
	"t37": {"coord": Vector2i(3, 0), "page": maps, "grid": 1}, #pandemonium
	"t38": {"coord": Vector2i(4, 0), "page": maps, "grid": 1}, #canyon
	"t16": {"coord": Vector2i(5, 0), "page": maps, "grid": 1}, #ruined
	"t3a": {"coord": Vector2i(6, 0), "page": maps, "grid": 1}, #ashen
	"t17": {"coord": Vector2i(7, 0), "page": maps, "grid": 1}, #halls
	"t29": {"coord": Vector2i(8, 0), "page": maps, "grid": 1}, #fortress
	"t2a": {"coord": Vector2i(0, 1), "page": maps, "grid": 1}, #descent
	"t13": {"coord": Vector2i(0, 0), "page": maps, "grid": 2}, #bastion
	"t23": {"coord": Vector2i(1, 0), "page": maps, "grid": 2}, #arreat
	"t31": {"coord": Vector2i(2, 0), "page": maps, "grid": 2}, #river
	"t35": {"coord": Vector2i(3, 0), "page": maps, "grid": 2}, #blood
	"t39": {"coord": Vector2i(4, 0), "page": maps, "grid": 2}, #market
	"t15": {"coord": Vector2i(5, 0), "page": maps, "grid": 2}, #royal
	"t28": {"coord": Vector2i(6, 0), "page": maps, "grid": 2}, #skovos
	"t27": {"coord": Vector2i(7, 0), "page": maps, "grid": 2}, #demon
	"t3b": {"coord": Vector2i(8, 0), "page": maps, "grid": 2}, #kyovashad
}


func _ready() -> void:
	StashRegistry.pd2_shared_registered.connect(init_materials)


func init_materials() -> void:
	var materials_page := StashRegistry.get_pd2_shared_save_file().materials_page
	if _initialized:
		reset()
	var items := materials_page.get_materials()
	for item: D2Item in items:
		var place_parameters: Dictionary = materials_place_map.get(item.code_string, {})
		if place_parameters.is_empty():
			continue
		item.x_coord = place_parameters["coord"].x
		item.y_coord = place_parameters["coord"].y
		var stash_page: MaterialStashPageGUI = place_parameters["page"]
		var grid := stash_page.grids[place_parameters["grid"]]
		grid.add_item_rect(item)
	_initialized = true


func reset() -> void:
	for page: MaterialStashPageGUI in all_pages:
		for grid: StashPageGUI in page.grids:
			grid._reset()
