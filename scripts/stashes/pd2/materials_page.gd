class_name MaterialsPage

const MATERIALS_BYTE_MAP: Dictionary[int, String] = { # 82-276
	# ===== Runes =====
	82: "r01s", #el
	84: "r02s", #eld
	86: "r03s", #tir
	88: "r04s", #nef
	90: "r05s", #eth
	92: "r06s", #ith
	94: "r07s", #tal
	96: "r08s", #ral
	98: "r09s", #ort
	100: "r10s", #thul
	102: "r11s", #amn
	104: "r12s", #sol
	106: "r13s", #shael
	108: "r14s", #dol
	110: "r15s", #hel
	112: "r16s", #io
	114: "r17s", #lum
	116: "r18s", #ko
	118: "r19s", #fal
	120: "r20s", #lem
	122: "r21s", #pul
	124: "r22s", #um
	126: "r23s", #mal
	128: "r24s", #ist
	130: "r25s", #gul
	132: "r26s", #vex
	134: "r27s", #ohm
	136: "r28s", #lo
	138: "r29s", #sur
	140: "r30s", #ber
	142: "r31s", #jah
	144: "r32s", #cham
	146: "r33s", #zod
	# ===== Gems =====
	148: "glys", #flawless topaz
	150: "glws", #flawless diamond
	152: "gzvs", #flawless amethyst
	154: "glbs", #flawless sapphire
	156: "glgs", #flawless emerald
	158: "glrs", #flawless ruby
	160: "skls", #flawless skull
	162: "gpys", #perfect topaz
	164: "gpws", #perfect diamond
	166: "gpvs", #perfect amethyst
	168: "gpbs", #perfect sapphire
	170: "gpgs", #pefect emerald
	172: "gprs", #perfect ruby
	174: "skzs", #perect skull
	176: "crfu", #bounty craft
	178: "crfp", #brilliant craft
	180: "crfc", #caster craft
	182: "crfh", #hitpower craft
	184: "crfs", #safety craft
	186: "crfb", #blood craft
	188: "crfv", #vampiric craft
	# ===== Organs =====
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
	# ===== Potions =====
	226: "rvs", #rejuv
	228: "rvl", #full rejuv
	# ===== Craft mats =====
	230: "imrn", #demonic cube
	232: "jewf", #jewel fragments
	234: "cwss", #twss
	236: "wss", #wss
	238: "lbox", #pbox
	240: "lpp", #ppiece
	# ===== Essences =====
	242: "tes", #blue
	244: "ceh", #yellow
	246: "bet", #red
	248: "fed", #green
	# ===== Map mats =====
	250: "std", #standard
	252: "iwss", #catalyst
	254: "upmp", #cartographer
	256: "irma", #infused arcane
	258: "urma", #infused angelic
	260: "irra", #infused zakarum
	262: "rrra", #infused horadric
	264: "scrb", #scarab
	266: "fort", #fortify
	268: "scou", #destruction
	270: "imma", #arcane
	272: "upma", #angelic
	274: "imra", #zakarum
	276: "rera", #horadric
}

var _data: PackedByteArray

var _materials: Array[D2Item]


func _init(data: PackedByteArray) -> void:
	_data = data
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
