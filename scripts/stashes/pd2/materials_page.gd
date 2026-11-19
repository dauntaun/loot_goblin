class_name MaterialsPage


const MATERIALS_BYTE_MAP: Dictionary[int, String] = { # 82-276
	# ===== Runes =====
	82: "r01", #el
	84: "r02", #eld
	86: "r03", #tir
	88: "r04", #nef
	90: "r05", #eth
	92: "r06", #ith
	94: "r07", #tal
	96: "r08", #ral
	98: "r09", #ort
	100: "r10", #thul
	102: "r11", #amn
	104: "r12", #sol
	106: "r13", #shael
	108: "r14", #dol
	110: "r15", #hel
	112: "r16", #io
	114: "r17", #lum
	116: "r18", #ko
	118: "r19", #fal
	120: "r20", #lem
	122: "r21", #pul
	124: "r22", #um
	126: "r23", #mal
	128: "r24", #ist
	130: "r25", #gul
	132: "r26", #vex
	134: "r27", #ohm
	136: "r28", #lo
	138: "r29", #sur
	140: "r30", #ber
	142: "r31", #jah
	144: "r32", #cham
	146: "r33", #zod
	# ===== Gems =====
	148: "gly", #flawless topaz
	150: "glw", #flawless diamond
	152: "gzv", #flawless amethyst
	154: "glb", #flawless sapphire
	156: "glg", #flawless emerald
	158: "glr", #flawless ruby
	160: "skl", #flawless skull
	162: "gpy", #perfect topaz
	164: "gpw", #perfect diamond
	166: "gpv", #perfect amethyst
	168: "gpb", #perfect sapphire
	170: "gpg", #pefect emerald
	172: "gpr", #perfect ruby
	174: "skz", #perect skull
	176: "crfu", #bounty craft
	178: "crfp", #brilliant craft
	180: "crfc", #caster craft
	182: "crfh", #hitpower craft
	184: "crfs", #safety craft
	186: "crfb", #blood craft
	188: "crfv", #vampiric craft
	# ===== Ubers =====
	190: "pk1", #key1
	192: "pk2", #key2
	194: "pk3", #key3
	196: "mbr", #brain
	198: "bey", #eye
	200: "dhn", #horn
	202: "ubaa", #T1 sigil
	204: "ubab", #T2 sigil
	206: "ubac", #T3 sigil
	208: "dcbl", #PDE
	210: "dcso", #PES
	212: "dcho", #black soulstone
	214: "rtmo", #jawbone
	216: "rtmv", #splinter
	218: "cm2f", #hellfire ash
	220: "lucb", #demonic insignia
	222: "lucc", #talisman of transgression
	224: "lucd", #flesh of malic
	226: "ubtm", #pandemonium
	228: "uba", #ancients
	230: "dcma", #vision of terror
	232: "rtma", #voidstone
	234: "luca", #shadow of hatred
	# ===== Misc =====
	236: "rvs", #rejuv
	238: "rvl", #full rejuv
	240: "imrn", #demonic cube
	242: "jewf", #jewel fragments
	244: "cwss", #twss
	246: "wss", #wss
	248: "lbox", #pbox
	250: "lpp", #ppiece
	252: "tes", #blue
	254: "ceh", #yellow
	256: "bet", #red
	258: "fed", #green
	# ===== Map mats =====
	260: "std", #standard
	262: "iwss", #catalyst
	264: "upmp", #cartographer
	266: "irma", #infused arcane
	268: "urma", #infused angelic
	270: "irra", #infused zakarum
	272: "rrra", #infused horadric
	274: "scrb", #scarab
	276: "fort", #fortify
	278: "scou", #destruction
	280: "imma", #arcane
	282: "upma", #angelic
	284: "imra", #zakarum
	286: "rera", #horadric
	288: "ivea", #ass
	290: "ivez", #ama
	292: "iveb", #bar
	294: "ived", #dru
	296: "iven", #nec
	298: "ivep", #pal
	300: "ives", #sor
	# ===== Misc 2 =====
	302: "toa", #token
	304: "llmr", #mirror
	306: "lsvl", #vial
	# ===== Maps =====
	#t1
	312: "t11", #viz-jun
	314: "t21", #phleg
	316: "t22", #torajan
	318: "t24", #tomb
	320: "t33", #lost
	322: "t34", #ancestral
	324: "t36", #fall
	326: "t26", #shadows
	#t2
	328: "t12", #horazon
	330: "t25", #sewers
	332: "t32", #throne
	334: "t37", #pandemonium
	336: "t38", #canyon
	338: "t14", #sanatorium
	340: "t16", #ruined
	342: "t3a", #ashen
	344: "t17", #halls
	#t3
	346: "t13", #bastion
	348: "t23", #arreat
	350: "t31", #river
	352: "t35", #blood
	354: "t39", #market
	356: "t15", #royal
	358: "t28", #skovos
	360: "t27", #demon
	362: "t3b", #kyovashad
	#new
	364: "t29", #fortress
	366: "t18", #poisoned
	368: "t2a", #descent
	# ===== Gems 2 =====
	432: "gcy", #chipped topaz
	434: "gcw", #chipped diamond
	436: "gcv", #chipped amethyst
	438: "gcb", #chipped sapphire
	440: "gcg", #chipped emerald
	442: "gcr", #chipped ruby
	444: "skc", #chipped skull
	446: "gfy", #flawed topaz
	448: "gfw", #flawed diamond
	450: "gfv", #flawed amethyst
	452: "gfb", #flawed sapphire
	454: "gfg", #flawed emerald
	456: "gfr", #flawed ruby
	458: "skf", #flawed skull
	460: "gsy", #topaz
	462: "gsw", #diamond
	464: "gsv", #amethyst
	466: "gsb", #sapphire
	468: "gsg", #emerald
	470: "gsr", #ruby
	472: "sku", #skull
}

const SHARED_GOLD_BYTE_OFFSET := 308
const SHARED_GOLD_BYTE_LENGTH := 4

var _data: PackedByteArray

var _materials: Array[D2Item]
var _shared_gold: int


func _init(data: PackedByteArray) -> void:
	_data = data
	_shared_gold = _data.decode_u32(SHARED_GOLD_BYTE_OFFSET)
	for byte_offset: int in MATERIALS_BYTE_MAP:
		var item_quantity := _data.decode_u16(byte_offset)
		if item_quantity > 0:
			_materials.append(_create_item_for_materials_page(MATERIALS_BYTE_MAP[byte_offset], item_quantity))


func _create_item_for_materials_page(code_string: String, quantity: int) -> D2Item:
	var item := D2Item.new()
	item.is_simple = true
	item.code_string = code_string
	# Taken from item_parser.gd
	item.item_type = TxtDB.get_item_type(code_string)
	item.item_class = TxtDB.get_item_class(code_string)
	item.item_tier = TxtDB.get_item_tier(code_string)
	item.inv_width = TxtDB.get_item_dimensions(code_string).x
	item.inv_height = TxtDB.get_item_dimensions(code_string).y
	item.base_name = TxtDB.get_item_base_name(code_string)
	item.is_misc = TxtDB.item_is_misc(code_string)
	item.is_rune = TxtDB.item_is_rune(code_string)
	item.is_tome = TxtDB.item_is_tome(code_string)
	item.is_stackable = true
	item.quantity = quantity
	item.item_name = item.base_name
	item.build_search_cache()
	return item


func get_materials() -> Array[D2Item]:
	return _materials
