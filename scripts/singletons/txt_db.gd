extends Node

const CACHE_PATH := "user://txtdb_cache.res"

const CORRUPTED_STAT_ID := 360

const TREASURE_CLASS_ITEMS := {
 "TC87": ["6ws", "7wa", "nef", "7ws", "7gd", "uhc", "urn", "ci3", "obf", "drf", "7wc", "7gi", "baf", "6lw", "7bl", "uhb", "7wd", "uhg", "uar", "7qr", "7gm", "7gw", "paf", "7p7", "7ts"],
 "TC84": ["utp", "uh9", "7ga", "7ls", "6rx", "7kr", "7st", "7h7", "uth", "7wh", "uul", "6bs", "dre", "utc", "obe", "uts", "pae"],
 "TC81": ["uow", "7fb", "bae", "7pa", "7gl", "uld", "ame", "utb", "7tw", "uhm", "nee", "6sw", "7mp", "7b8"],
 "TC78": ["upl", "7b7", "7bs", "6l7", "utg", "drd", "7lw", "amc", "ult", "7fl", "7qs", "ush", "7bk"],
 "TC75": ["xts", "7cs", "6hx", "7bt", "usk", "obd", "bad", "6cs", "urs", "7bw", "ucl", "7br", "umc", "7cr"],
 "TC72": ["7gs", "7s7", "umb", "7mt", "6s7", "ung", "72a", "7di", "uit", "pac", "7s8", "ci2", "utu"],
 "TC69": ["ulm", "upk", "obc", "6mx", "6cb", "neg", "7fc", "7m7", "ula", "drc", "umg", "uvc", "7xf", "uea"],
 "TC66": ["7vo", "uui", "7tk", "bac", "7yw", "7cm", "urg", "amf", "xar", "ned", "uvb", "7ba", "6ls", "7tr"],
 "TC63": ["7sm", "drb", "uhn", "xul", "7sb", "ukp", "uml", "amd", "7sc", "7ma", "pab", "6lb", "7ax", "ulc", "7pi", "uvg", "7wb"],
 "TC60": ["6hb", "7dg", "bab", "xth", "uuc", "obb", "7sr", "72h", "xtp", "neb", "7o7", "uap", "7ar", "6ss", "ulb"],
 "TC57": ["xts", "ulg", "7ss", "7la", "7ta", "xrn", "9wc", "6lx", "7wn", "paa", "xld", "6sb", "dra", "7sp"],
 "TC54": ["8rx", "ci1", "9gd", "uhl", "8lw", "nea", "7ja", "9gm", "amb", "9qr", "baa", "xlt", "7ha", "7cl", "zhb", "xhb", "xhg"],
 "TC51": ["9gi", "9wd", "ztb", "xtb", "xtg", "9h9", "ne9", "am9", "9gw", "9tw", "xh9", "pa9", "9ts", "xow", "8sw", "xpl", "dr9", "ba9", "oba", "xhm", "9fb"],
 "TC48": ["8hx", "9wh", "am7", "xrs", "xsk", "9ga", "9b9", "xsh", "dr8", "9p9", "8l8", "9wa", "pa8", "8ws", "ob9", "9bl"],
 "TC45": ["xhl", "am8", "9mp", "9sm", "9ws", "xit", "9lw", "xmg", "9fl", "xhn", "zmb", "xmb", "ba8", "9ls", "ne8", "8s8", "xcl", "9bw", "9gs", "9m9", "9st"],
 "TC42": ["pa7", "aar", "xpk", "9s8", "9bs", "xlm", "9kr", "ob8", "9cm", "8bs", "dr7", "9cs", "9qs", "9b8", "xng", "xrg", "8mx", "9s9", "9bt", "xtu", "9br"],
 "TC39": ["am6", "9ba", "9vo", "8cs", "ob7", "xla", "9cr", "8cb", "92h", "ne7", "ful", "9pi", "9mt", "ba7", "9yw", "xml", "xkp", "zvb", "xvb", "xvg", "9fc", "92a", "9bk"],
 "TC36": ["pa6", "dr6", "8lx", "8lb", "ama", "9ax", "xuc", "xlb", "zlb", "9xf", "9ma", "9ta", "9tr", "xui", "ltp", "9la", "9pa", "8ls", "9di", "xea", "9sb", "xap", "wsc"],
 "TC33": ["9sp", "9tk", "9wn", "xlg", "ob6", "gth", "gma", "gsd", "9ha", "ba6", "9b7", "lwb", "ne6", "9dg", "8hb", "rxb", "9sc", "9sr", "9wb"],
 "TC30": ["crn", "9cl", "8sb", "fld", "9ss", "gts", "hal", "8ss", "9ar", "tsp", "9ja"],
 "TC27": ["flb", "hgl", "gix", "hbl", "gwn", "am4", "hbt", "am2", "swb", "wax", "whm", "wsd"],
 "TC24": ["ba5", "bsw", "bld", "bhm", "ci0", "pa5", "ne5", "ob5", "glv", "gax", "ghm", "hxb", "lbb", "am5", "pik", "plt", "skr", "dr5", "tow", "wst"],
 "TC21": ["pa4", "ba4", "btl", "bsh", "dr4", "fla", "ne4", "gis", "tbl", "tgl", "tbt", "lsd", "msk", "mau", "mpi", "pax", "spt", "spl", "wsp"],
 "TC18": ["dr3", "bal", "btx", "bst", "bwn", "brn", "brs", "ob4", "clw", "clm", "pa3", "ba3", "kri", "am3", "sbb", "am1", "ne3"],
 "TC15": ["bkf", "bsd", "ces", "chn", "mxb", "2ax", "fhl", "gsc", "kit", "mst", "scl", "scy", "ssp"],
 "TC12": ["mbl", "bax", "mbt", "mgl", "cbw", "crs", "flc", "cst", "axf", "hlm", "lrg", "pil", "rng", "ob3", "spk", "2hs", "vou", "ywn"],
 "TC9": ["axe", "dir", "ba2", "dr2", "vbt", "vgl", "vbl", "lbw", "lst", "mac", "pa2", "sbr", "ob2", "stu", "tax", "tri", "wrb", "ne2"],
 "TC6": ["bar", "hla", "hbw", "ba1", "lax", "lxb", "ne1", "scm", "skp", "sml", "spr", "spc", "pa1", "dr1"],
 "TC3": ["buc", "cap", "clb", "dgr", "ob1", "hax", "jav", "ktr", "lea", "lbt", "lgl", "qui", "lbl", "scp", "sbw", "sst", "ssd", "tkf", "wnd"],
}

const DCLONE_CODES := ["utb", "uhl", "uth", "7qr", "7bs"]
const RATHMA_CODES := ["rbe", "rar", "ram"]
const CLASS_ID_BY_CODE: Dictionary[String, int] = {
	"ama": 0,
	"sor": 1,
	"nec": 2,
	"pal": 3,
	"bar": 4,
	"dru": 5,
	"ass": 6,
	"" : 99
}

const HIDDEN_STATS = [23, 24] ## Secondary min/max damage

const DGRPS: Dictionary[int, Dictionary] = {
	1 : {"count": 4, "id": 999}, # All stats
	2 : {"count": 4, "id": 1000}, # All res
	6 : {"count": 2, "id": 1001}, # Map MF/GF
	4 : {"count": 2, "id": 1002}, # Map mob attack/cast rate
	5 : {"count": 2, "id": 1003}, # Map pierce/ar
	8 : {"count": 4, "id": 1004}, # Map max all res
	3 : {"count": 4, "id": 1005}, # Map all res
	7 : {"count": 2, "id": 1006}, # Map player attack/cast rate
	99 : {"count": 2, "id": 2001}, # Enhanced Damage (custom)
}

const MGRPS: Dictionary[int, int] = { ## mgrp : stat_id
	1 : 2002,
	2 : 2003,
	3 : 2004,
	4 : 2005,
	5 : 2006,
	6 : 2007,
}

const CUSTOM_STATS: Dictionary[int, Dictionary] = {
	# Native DGRPs
	999 : {"Stat": "item_allatt", "descfunc": 1, "descval": 1, "descpriority": 61, "descstrpos": "Moditem2allattrib", "descstrneg": "Moditem2allattrib", "descstr2": ""},
	1000: {"Stat": "item_allres", "descfunc": 19, "descval": 0, "descpriority": 34, "descstrpos": "strModAllResistances", "descstrneg": "strModAllResistancesNeg", "descstr2": ""},
	1001: {"Stat": "map_mfgf", "descfunc": 4, "descval": 2, "descpriority": 210, "descstrpos": "MapGlobMFGF", "descstrneg": "MapGlobMFGF", "descstr2": ""},
	1002: {"Stat": "map_atkcast", "descfunc": 8, "descval": 2, "descpriority": 142, "descstrpos": "MapMonHave", "descstrneg": "MapMonHave", "descstr2": "MapAtkCastRate"},
	1003: {"Stat": "map_piercear", "descfunc": 8, "descval": 2, "descpriority": 115, "descstrpos": "MapMonHave", "descstrneg": "MapMonHave", "descstr2": "MapPierceAR"},
	1004: {"Stat": "map_playmaxres", "descfunc": 7, "descval": 2, "descpriority": 201, "descstrpos": "MapPlayHave", "descstrneg": "MapPlayHave", "descstr2": "MapPlayMaxAllRes"},
	1005: {"Stat": "map_playres", "descfunc": 7, "descval": 2, "descpriority": 201, "descstrpos": "MapPlayHave", "descstrneg": "MapPlayHave", "descstr2": "MapPlayAllRes"},
	1006: {"Stat": "map_playatkcast", "descfunc": 7, "descval": 2, "descpriority": 142, "descstrpos": "MapPlayHave", "descstrneg": "MapPlayHave", "descstr2": "MapAtkCastSpeed"},
	# Custom DGRP
	2001 : {"Stat": "item_dmg%", "descfunc": 19, "descpriority": 129, "descstrpos": "+%d%% Enhanced Damage"},
	# Custom MGRPs
	2002 : {"Stat": "item_firerange", "descfunc": 101, "descpriority": 101, "descstrpos": "Adds %d-%d fire damage"},
	2003 : {"Stat": "item_lightrange", "descfunc": 101, "descpriority": 98, "descstrpos": "Adds %d-%d lightning damage"},
	2004 : {"Stat": "item_magicrange", "descfunc": 101, "descpriority": 103, "descstrpos": "Adds %d-%d magic damage"},
	2005 : {"Stat": "item_coldrange", "descfunc": 101, "descpriority": 95, "descstrpos": "Adds %d-%d cold damage"},
	2006 : {"Stat": "item_poisonrange", "descfunc": 102, "descpriority": 91, "descstrpos": "+%d poison damage over %d seconds"},
	2007 : {"Stat": "item_damrange", "descfunc": 101, "descpriority": 126, "descstrpos": "Adds %d-%d damage"},
}

const MODIFY_STATS: Dictionary[int, Dictionary] = {
	17 : {"dgrp": 99}, # Enhanced damage
	18 : {"dgrp": 99},
	48 : {"mgrp": 1}, # Fire dmg
	49 : {"mgrp": 1},
	50 : {"mgrp": 2}, # Light dmg
	51 : {"mgrp": 2},
	52 : {"mgrp": 3}, # Magic dmg
	53 : {"mgrp": 3},
	54 : {"mgrp": 4}, # Cold dmg
	55 : {"mgrp": 4},
	56 : {"mgrp": 4},
	57 : {"mgrp": 5}, # Poison dmg
	58 : {"mgrp": 5},
	59 : {"mgrp": 5},
	21 : {"mgrp": 6}, # Damage
	22 : {"mgrp": 6},
}

const MODIFY_TBL: Dictionary[String, String] = {
	"StrSklTabItem6" : "+%d to Combat Skills",
}

const CUSTOM_PROPERTIES: Dictionary[String, Dictionary] = {
	"dmg-max": {"stat1": "mindamage", "stat2": "secondary_mindamage", "stat3": "item_throw_mindamage"},
	"dmg-min": {"stat1": "maxdamage", "stat2": "secondary_maxdamage", "stat3": "item_throw_maxdamage"},
	"dmg%": {"stat1": "item_mindamage_percent", "stat2": "item_maxdamage_percent"},
	"indestruct": {"stat1": "item_indesctructible"}
}

const MODIFY_GEMS: Dictionary[String, Dictionary] = {
	"r07" : {"weaponMod1Code": "pois-min", "weaponMod1Min": 154, "weaponMod2Code": "pois-max", "weaponMod2Min": 154, "weaponMod3Code": "pois-len", "weaponMod3Min": 125},
	"r08" : {"weaponMod1Code": "fire-min", "weaponMod1Min": 5, "weaponMod2Code": "fire-max", "weaponMod2Min": 30},
	"r09" : {"weaponMod1Code": "ltng-min", "weaponMod1Min": 5, "weaponMod2Code": "ltng-max", "weaponMod2Min": 30},
	"r10" : {"weaponMod1Code": "cold-min", "weaponMod1Min": 3, "weaponMod2Code": "cold-max", "weaponMod2Min": 14, "weaponMod3Code": "cold-len", "weaponMod3Min": 75},
}

const RENAME_TYPES: Dictionary[String, String] = {
	"Knife": "Dagger",
	"Scythe Type": "Polearm",
	"Hand to Hand 2": "Claw",
	"Hand to Hand": "Claw",
	"Primal Helm": "Barbarian Helm",
	"Voodoo Heads": "Necromancer Shield",
	"Auric Shields": "Paladin Shield",
	"Pelt": "Druid Helm",
	"Large Charm": "Grand Charm",
	"Medium Charm": "Large Charm",
	"Amulet [S]": "Amulet",
	"Belt [S]": "Belt",
}

var all_codes: Dictionary
var weapon_codes: Dictionary
var armor_codes: Dictionary
var misc_codes: Dictionary
var magic_prefix: Dictionary
var magic_suffix: Dictionary
var rare_prefix: Dictionary
var rare_suffix: Dictionary
var unique_items: Dictionary
var set_items: Dictionary
var item_types: Dictionary
var runewords: Dictionary
var runewords_parsed: Dictionary
var damage_ranges: Dictionary
var item_stat_cost: Dictionary
var stat_cost_parsed: Dictionary
var item_stat_cost_by_code: Dictionary
var localization_table: Dictionary
var skill_table: Dictionary
var skill_desc: Dictionary
var charstat_table: Dictionary
var monster_table: Dictionary
var monstertype_table: Dictionary
var gems: Dictionary
var gem_props: Dictionary
var properties: Dictionary


func _ready() -> void:
	if GlobalSettings.force_update_cache:
		_build_database()
		return
	if ResourceLoader.exists(CACHE_PATH):
		var cache := ResourceLoader.load(CACHE_PATH) as CachedTxtDB
		if cache:
			_load_from_cache(cache)
		else:
			_build_database()
	else:
		_build_database()


func _load_from_cache(cache: CachedTxtDB) -> void:
	all_codes = cache.all_codes
	weapon_codes = cache.weapon_codes
	armor_codes = cache.armor_codes
	misc_codes = cache.misc_codes
	item_types = cache.item_types
	magic_prefix = cache.magic_prefix
	magic_suffix = cache.magic_suffix
	rare_prefix = cache.rare_prefix
	rare_suffix = cache.rare_suffix
	unique_items = cache.unique_items
	set_items = cache.set_items
	runewords_parsed = cache.runewords_parsed
	damage_ranges = cache.damage_ranges
	item_stat_cost = cache.item_stat_cost
	stat_cost_parsed = cache.stat_cost_parsed
	item_stat_cost_by_code = cache.item_stat_cost_by_code
	localization_table = cache.localization_table
	skill_table = cache.skill_table
	skill_desc = cache.skill_desc
	charstat_table = cache.charstat_table
	monster_table = cache.monster_table
	monstertype_table = cache.monstertype_table
	gems = cache.gems
	gem_props = cache.gem_props
	properties = cache.properties
	# D2Colors
	D2Colors.orange_item_codes = cache.orange_item_codes
	D2Colors.gold_item_codes = cache.gold_item_codes
	D2Colors.purple_item_codes = cache.purple_item_codes
	D2Colors.red_item_codes = cache.red_item_codes
	# Grail
	Grail.grail_uniques = cache.grail_uniques
	Grail.grail_sets = cache.grail_sets


func _save_database_cache() -> void:
	var cache := CachedTxtDB.new()
	cache.all_codes = all_codes
	cache.weapon_codes = weapon_codes
	cache.armor_codes = armor_codes
	cache.misc_codes = misc_codes
	cache.magic_prefix = magic_prefix
	cache.magic_suffix = magic_suffix
	cache.rare_prefix = rare_prefix
	cache.rare_suffix = rare_suffix
	cache.unique_items = unique_items
	cache.set_items = set_items
	cache.item_types = item_types
	cache.runewords = runewords
	cache.runewords_parsed = runewords_parsed
	cache.damage_ranges = damage_ranges
	cache.item_stat_cost = item_stat_cost
	cache.stat_cost_parsed = stat_cost_parsed
	cache.item_stat_cost_by_code = item_stat_cost_by_code
	cache.localization_table = localization_table
	cache.skill_table = skill_table
	cache.skill_desc = skill_desc
	cache.charstat_table = charstat_table
	cache.monster_table = monster_table
	cache.monstertype_table = monstertype_table
	cache.gems = gems
	cache.gem_props = gem_props
	cache.properties = properties
	# D2Colors
	cache.orange_item_codes = D2Colors.orange_item_codes
	cache.gold_item_codes = D2Colors.gold_item_codes
	cache.purple_item_codes = D2Colors.purple_item_codes
	cache.red_item_codes = D2Colors.red_item_codes
	# Grail
	cache.grail_uniques = Grail.grail_uniques
	cache.grail_sets = Grail.grail_sets
	ResourceSaver.save(cache, CACHE_PATH)


func _build_database() -> void:
	# -----------------------------
	# Load Item Codes
	# -----------------------------
	weapon_codes = _load_csv_as_dict("txt/Weapons.txt", "code", ["name", "type", "normcode", "ubercode", "ultracode", "stackable", "invwidth", "invheight", "reqstr", "reqdex", "levelreq", "mindam", "maxdam", "2handmindam", "2handmaxdam", "minmisdam", "maxmisdam", "namestr", "2handed"], true)
	armor_codes = _load_csv_as_dict("txt/Armor.txt", "code", ["name", "type", "normcode", "ubercode", "ultracode", "stackable", "invwidth", "invheight", "reqstr", "reqdex", "levelreq", "namestr"], true)
	misc_codes = _load_csv_as_dict("txt/Misc.txt", "code", ["name", "type", "normcode", "ubercode", "ultracode", "stackable", "invwidth", "invheight", "reqstr", "reqdex", "levelreq", "namestr"], true)
	item_types = _load_csv_as_dict("txt/ItemTypes.txt", "Code", ["ItemType", "Equiv1", "Equiv2", "Class"], true)
	all_codes = weapon_codes.merged(armor_codes)
	all_codes.merge(misc_codes)
	
	# -----------------------------
	# Magic / Rare / Unique / Set / Runes
	# -----------------------------
	magic_prefix = _load_csv_as_dict("txt/MagicPrefix.txt", "", ["Name", "mod1code", "levelreq"], true)
	magic_suffix = _load_csv_as_dict("txt/MagicSuffix.txt", "", ["Name", "mod1code", "levelreq"], true)
	rare_prefix = _load_csv_as_dict("txt/RarePrefix.txt", "", ["name"])
	rare_suffix = _load_csv_as_dict("txt/RareSuffix.txt", "", ["name"])
	unique_items = _load_csv_as_dict("txt/UniqueItems.txt", "", ["index", "lvl", "lvl req", "enabled", "rarity", "code", "prop1", "prop2", "prop3", "prop4", "prop5", "prop6", "prop7", "prop8", "prop9", "prop10", "prop11", "prop12"], true)
	set_items = _load_csv_as_dict("txt/SetItems.txt", "", ["index", "set", "item", "rarity", "lvl", "lvl req", "prop1", "prop2", "prop3", "prop4", "prop5", "prop6", "prop7", "prop8"], true)
	runewords = _load_csv_as_dict("txt/Runes.txt", "")
	gems = _load_csv_as_dict("txt/Gems.txt", "code")
	properties = _load_csv_as_dict("txt/Properties.txt", "code", ["code", "stat1", "stat2", "stat3", "stat4"])
	item_stat_cost = _load_csv_as_dict("txt/ItemStatCost.txt", "", 
	["Stat", "ID", "Save Bits", "Save Add", "Encode", "Save Param Bits", "CSvBits",
	"descfunc", "descstrpos", "descstrneg", "descstr2", "descpriority", "op", "fMin", "MinAccr", "descval",
	"dgrp", "dgrpfunc", "dgrpval", "dgrpstrpos", "dgrpstrneg", "dgrpstr2", "ValShift"])
	
	# Rename item types
	for rename: String in RENAME_TYPES:
		for item_type in item_types:
			if item_types[item_type]["ItemType"] == rename:
				item_types[item_type]["ItemType"] = RENAME_TYPES[rename]
				break
	# Setup chained stats for parser
	for id in item_stat_cost.keys():
		var stat = item_stat_cost[id]
		if stat["ID"] in ["17", "48", "50", "52", "54", "55", "57", "58"]:
			stat["next_in_chain"] = int(stat["ID"]) + 1
		else:
			stat["next_in_chain"] = 0
	# Setup merged stats for formatter
	for grp: int in MODIFY_STATS:
		var stat: Dictionary = item_stat_cost[grp]
		for key: String in MODIFY_STATS[grp]:
			stat[key] = MODIFY_STATS[grp][key]
	for custom_id: int in CUSTOM_STATS:
		item_stat_cost[custom_id] = CUSTOM_STATS[custom_id]
	# Setup hidden stats
	for stat_id: int in HIDDEN_STATS:
		item_stat_cost[stat_id]["descfunc"] = 0
	
	# Setup localization
	localization_table = {}
	var tbl_files := ["txt/tbl/patchstring.txt", "txt/tbl/expansionstring.txt", "txt/tbl/string.txt"]
	for f: String in tbl_files:
		var tbl_data = _load_csv_as_dict(f, "String Index", ["Text"], true)
		localization_table.merge(tbl_data)
	# Fix broken keys
	for key: String in MODIFY_TBL:
		localization_table[key]["Text"] = MODIFY_TBL[key]
	# Clean color tags and cache codes in D2Colors
	var regex := RegEx.create_from_string("\\\\([A-Za-z]+);")
	for key in misc_codes:
		var localization_key = misc_codes[key]["namestr"]
		var item_name := localize(localization_key)
		var search_result: RegExMatch = regex.search(item_name)
		if search_result:
			item_name = regex.sub(item_name, "", true)
			localization_table[localization_key]["Text"] = item_name
			match search_result.get_string(1):
				"orange":
					D2Colors.orange_item_codes.append(key)
				"gold":
					D2Colors.gold_item_codes.append(key)
				"red":
					D2Colors.red_item_codes.append(key)
				"purple":
					D2Colors.purple_item_codes.append(key)
	# Skill / Charstat / Monster tables
	skill_table = _load_csv_as_dict("txt/Skills.txt", "Id", ["skill", "charclass", "skilldesc"])
	skill_desc = _load_csv_as_dict("txt/SkillDesc.txt", "skilldesc", ["str name"])
	charstat_table = _load_csv_as_dict("txt/CharStats.txt", "", ["StrAllSkills", "StrSkillTab1", "StrSkillTab2", "StrSkillTab3", "StrClassOnly"], true)
	monster_table = _load_csv_as_dict("txt/MonStats.txt", "", ["NameStr"], true)
	monstertype_table = _load_csv_as_dict("txt/MonType.txt", "", ["strplur"])
	
	# Setup gem props
	for gem_code: String in MODIFY_GEMS:
		var gem_dict: Dictionary = MODIFY_GEMS[gem_code]
		for key in gem_dict:
			gems[gem_code][key] = gem_dict[key]
	for mod: String in CUSTOM_PROPERTIES:
		properties[mod] = CUSTOM_PROPERTIES[mod]
	for stat_id: int in item_stat_cost:
		var code: String = item_stat_cost[stat_id]["Stat"]
		item_stat_cost_by_code[code] = item_stat_cost[stat_id]
	for code in gems:
		if code is int:
			continue
		var gem_row: Dictionary = gems[code]
		var weapon_mods = {
			"mod1" = {"code": gem_row["weaponMod1Code"], "param": int(gem_row["weaponMod1Param"]), "value": int(gem_row["weaponMod1Min"])},
			"mod2" = {"code": gem_row["weaponMod2Code"], "param": int(gem_row["weaponMod2Param"]), "value": int(gem_row["weaponMod2Min"])},
			"mod3" = {"code": gem_row["weaponMod3Code"], "param": int(gem_row["weaponMod3Param"]), "value": int(gem_row["weaponMod3Min"])},
			}
		var armor_mods = {
			"mod1" = {"code": gem_row["helmMod1Code"], "param": int(gem_row["helmMod1Param"]), "value": int(gem_row["helmMod1Min"])},
			"mod2" = {"code": gem_row["helmMod2Code"], "param": int(gem_row["helmMod2Param"]), "value": int(gem_row["helmMod2Min"])},
			"mod3" = {"code": gem_row["helmMod3Code"], "param": int(gem_row["helmMod3Param"]), "value": int(gem_row["helmMod3Min"])},
			}
		var shield_mods = {
			"mod1" = {"code": gem_row["shieldMod1Code"], "param": int(gem_row["shieldMod1Param"]), "value": int(gem_row["shieldMod1Min"])},
			"mod2" = {"code": gem_row["shieldMod2Code"], "param": int(gem_row["shieldMod2Param"]), "value": int(gem_row["shieldMod2Min"])},
			"mod3" = {"code": gem_row["shieldMod3Code"], "param": int(gem_row["shieldMod3Param"]), "value": int(gem_row["shieldMod3Min"])},
			}
		var weapon_props: Array = build_gem_props(weapon_mods)
		var armor_props: Array = build_gem_props(armor_mods)
		var shield_props: Array = build_gem_props(shield_mods)
	
		var gem_prop: Dictionary = {"weapon": weapon_props, "armor": armor_props, "shield": shield_props}
		gem_props[code] = gem_prop
	# Setup item stat costs
	for stat_id: int in item_stat_cost:
		var raw = item_stat_cost[stat_id]
		stat_cost_parsed[stat_id] = {
		"save_bits": int(raw.get("Save Bits", 0)),
		"save_param_bits": int(raw.get("Save Param Bits", 0)),
		"save_add": int(raw.get("Save Add", 0)),
		"encode": int(raw.get("Encode", 0)),
		"next_in_chain": int(raw.get("next_in_chain", 0)),
		"descfunc": int(raw.get("descfunc", 0)),
		"descstrpos": str(raw.get("descstrpos", "")),
		"descstrneg": str(raw.get("descstrneg", "")),
		"descstr2": str(raw.get("descstr2", "")),
		"descpriority": int(raw.get("descpriority", 0)),
		"op": int(raw.get("op", 0)),
		"descval": int(raw.get("descval", 0)),
		"dgrp": int(raw.get("dgrp", 0)),
		"dgrpfunc": int(raw.get("dgrpfunc", 0)),
		"dgrpval": int(raw.get("dgrpval", 0)),
		"dgrpstrpos": str(raw.get("dgrpstrpos", "")),
		"dgrpstrneg": str(raw.get("dgrpstrneg", "")),
		"dgrpstr2": str(raw.get("dgrpstr2", "")),
		"valshift": int(raw.get("ValShift", 0)),
		"mgrp": int(raw.get("mgrp", 0)),
		}
	
	# Setup runewords
	for row_num: int in runewords:
		var row: Dictionary = runewords[row_num]
		var rw_name: String = row["Name"]
		if row["complete"] == "1":
			var runes: Array[String]
			for i: int in range(1, 7):
				var key: String = "Rune%d" % i
				if row[key] != "":
					runes.append(row[key])
			runewords_parsed[rw_name] = runes
	# Setup grail sets
	var set_entries: Array[GrailEntry]
	for set_id: int in set_items:
		var row: Dictionary = set_items[set_id]
		var set_entry := GrailEntry.new()
		set_entry.item_rarity = D2Item.ItemRarity.SET
		var code_string: String = row["item"]
		# Setup tier and subcategory
		var tier := get_item_tier(code_string)
		set_entry.item_tier = D2Item.ItemTier.keys()[tier].capitalize()
		# Setup subcategory
		set_entry.subcategory = localize(row["set"])
		var main_category: String
		if set_entry.subcategory in Grail.common_sets:
			main_category = "Common"
		elif set_entry.subcategory in Grail.uncommon_sets:
			main_category = "Uncommon"
		else:
			main_category = "Class-Focused"
		set_entry.main_category = main_category
		# Setup TC
		set_entry.item_tc = get_item_tc(code_string)
		# Setup base name
		set_entry.item_base_name = get_item_base_name(code_string)
		# Setup eth
		var eth_possible: bool
		var has_eth: bool
		var has_indestruct: bool
		for i: int in range(1, 9):
			var prop_string: String = row["prop%d" % i]
			if prop_string == "ethereal":
				has_eth = true
				break
			elif prop_string == "indestruct":
				has_indestruct = true
		var type := get_item_type(code_string)
		set_entry.item_type = type
		eth_possible = has_eth or (not has_indestruct) and not type in ["Bow", "Amazon Bow", "Crossbow", "Amulet", "Ring"]
		set_entry.eth_possible = eth_possible
		set_entry.txt_id = set_id
		set_entry.item_name = localize(row["index"])
		set_entry.item_qlvl = int(row["lvl"])
		set_entries.append(set_entry)
		
	# Setup grail uniques
	var unique_entries: Array[GrailEntry]
	for unique_id: int in unique_items:
		var row: Dictionary = unique_items[unique_id]
		if int(row["enabled"]) != 1 or int(row["lvl"]) == 0:
			continue
		var unique_entry := GrailEntry.new()
		unique_entry.item_rarity = D2Item.ItemRarity.UNIQUE
		var code_string: String = row["code"]
		# Setup main category
		var main_category: String
		if code_string in DCLONE_CODES:
			main_category = "Uber"
		elif code_string in RATHMA_CODES:
			main_category = "Uber"
		elif item_is_weapon(row["code"]):
			main_category = "Weapon"
		elif item_is_armor(row["code"]):
			main_category = "Armor"
		else:
			main_category = "Misc"
		unique_entry.main_category = main_category
		# Setup subcategory
		var type := get_item_type(code_string)
		unique_entry.item_type = type
		var subcategory := type
		if code_string in DCLONE_CODES:
			subcategory = "DClone"
		elif code_string in RATHMA_CODES:
			subcategory = "Rathma"
		elif type in ["Small Charm", "Large Charm", "Grand Charm"]:
			subcategory = "Charm"
		elif type in ["Mace", "Club", "Hammer"]:
			if item_is_twohanded(code_string):
				subcategory = "Mace 2H"
			else:
				subcategory = "Mace 1H"
		elif type == "Sword":
			if item_is_twohanded(code_string):
				subcategory = "Sword 2H"
			else:
				subcategory = "Sword 1H"
		elif type == "Axe":
			if item_is_twohanded(code_string):
				subcategory = "Axe 2H"
			else:
				subcategory = "Axe 1H"
		elif type in ["Throwing Axe", "Throwing Knife", "Javelin"]:
			subcategory = "Throwing"
		elif type in ["Amazon Bow", "Amazon Spear", "Amazon Javelin"]:
			subcategory = "Amazon"
		elif type == "Bow Quiver":
			subcategory = "Arrows"
		elif type == "Crossbow Quiver":
			subcategory = "Bolts"
		elif type == "Map T5":
			subcategory = "Map"
		unique_entry.subcategory = subcategory
		# Setup tier
		var tier := get_item_tier(code_string)
		unique_entry.item_tier = D2Item.ItemTier.keys()[tier].capitalize()
		# Setup TC
		unique_entry.item_tc = get_item_tc(code_string)
		# Setup base name
		unique_entry.item_base_name = get_item_base_name(code_string)
		# Setup eth
		var eth_possible: bool
		var has_eth: bool
		var has_indestruct: bool
		for i: int in range(1, 13):
			var prop_string: String = row["prop%d" % i]
			if prop_string == "ethereal":
				has_eth = true
				break
			elif prop_string == "indestruct":
				has_indestruct = true
		eth_possible = has_eth or (not has_indestruct) and main_category != "Misc" and not type in ["Bow", "Amazon Bow", "Crossbow", "Amulet"]
		unique_entry.eth_possible = eth_possible
		unique_entry.txt_id = unique_id
		unique_entry.item_name = localize(row["index"])
		unique_entry.item_qlvl = int(row["lvl"])
		unique_entries.append(unique_entry)
	# Sort entries
	var tier_order := ["Normal", "Exceptional", "Elite"]
	var sort_grail_entries := func(a: GrailEntry, b: GrailEntry, main_category_order: Array, subcategory_order: Array) -> bool:
		if a.main_category != b.main_category:
			return main_category_order.find(a.main_category) < main_category_order.find(b.main_category)
		if a.subcategory != b.subcategory:
			return subcategory_order.find(a.subcategory) < subcategory_order.find(b.subcategory)
		#if a.item_type != b.item_type:
			#return a.item_type.naturalnocasecmp_to(b.item_type) < 0
		if a.item_tier != b.item_tier:
			return tier_order.find(a.item_tier) < tier_order.find(b.item_tier)
		if a.item_tc != b.item_tc:
			return a.item_tc.naturalnocasecmp_to(b.item_tc) < 0
		return a.item_qlvl < b.item_qlvl
	# Sort grail entries
	unique_entries.sort_custom(sort_grail_entries.bind(Grail.unique_main_categories, Grail.unique_subcategories))
	var grail_uniques: Dictionary[int, GrailEntry]
	for unique_entry: GrailEntry in unique_entries:
		grail_uniques[unique_entry.txt_id] = unique_entry
	Grail.grail_uniques = grail_uniques
	
	set_entries.sort_custom(sort_grail_entries.bind(Grail.set_main_categories, Grail.set_subcategories))
	var grail_sets: Dictionary[int, GrailEntry]
	for set_entry: GrailEntry in set_entries:
		grail_sets[set_entry.txt_id] = set_entry
	Grail.grail_sets = grail_sets
	
	# Setup damage ranges
	for code_string: String in weapon_codes:
		var weapon_stats: Dictionary = weapon_codes[code_string]
		var damage_dict: Dictionary = {}
		if weapon_stats["mindam"] != "":
			damage_dict["onehand"] = {"min": int(weapon_stats["mindam"]), "max": int(weapon_stats["maxdam"])}
		if weapon_stats["2handmindam"]:
			damage_dict["twohand"] = {"min": int(weapon_stats["2handmindam"]), "max": int(weapon_stats["2handmaxdam"])}
		if weapon_stats["minmisdam"]:
			damage_dict["throw"] = {"min": int(weapon_stats["minmisdam"]), "max": int(weapon_stats["maxmisdam"])}
		
		var eth_dict: Dictionary = damage_dict.duplicate_deep()
		for key: String in eth_dict:
			for dam: String in eth_dict[key]:
				eth_dict[key][dam] = floori(eth_dict[key][dam] * 1.25)
		
		damage_ranges[code_string] = {"regular": damage_dict, "eth": eth_dict}
	
	_save_database_cache()


func get_gem_properties(gem_code: String) -> Dictionary:
	return gem_props[gem_code]


func build_gem_props(gem_mods: Dictionary) -> Array:
	var props: Array
	for mod: String in gem_mods:
		var mod_params: Dictionary = gem_mods[mod]
		var mod_code: String = mod_params.code.to_lower()
		if mod_code == "":
			continue
		var mod_dict: Dictionary = properties[mod_code]
		for i: int in range(1, 5):
			var stat_string: String = "stat%d" % i
			var stat_code: String = properties[mod_code].get(stat_string, "")
			if stat_code == "":
				continue
			var stat_id: int = int(item_stat_cost_by_code[stat_code]["ID"])
			var prop: Dictionary = {"stat_id": stat_id, "params": [mod_params.value]}
			props.append(prop)
	return props

# ============================================================
# ITEM TYPE CHECKS
# ============================================================

func item_is_weapon(code_string: String) -> bool:
	return weapon_codes.has(code_string)

func item_is_twohanded(code_string: String) -> bool:
	if weapon_codes.has(code_string):
		return weapon_codes[code_string]["2handed"] == "1"
	return false

func item_is_armor(code_string: String) -> bool:
	return armor_codes.has(code_string)

func item_is_shield(code_string: String) -> bool:
	if armor_codes.has(code_string):
		return armor_codes[code_string]["type"] in ["shie", "head", "ashd"]
	return false

func item_is_misc(code_string: String) -> bool:
	return misc_codes.has(code_string)

func item_is_rune(code_string: String) -> bool:
	return all_codes[code_string]["type"] in ["rune", "runs"]

func item_is_tome(code_string: String) -> bool:
	return all_codes[code_string]["type"] == "book"

func item_is_stackable(code_string: String) -> bool:
	return all_codes[code_string]["stackable"] == "1"

func item_is_corrupted(prop_list: Array[Dictionary]) -> bool:
	for prop: Dictionary in prop_list:
		if prop.stat_id == CORRUPTED_STAT_ID:
			return true
	return false

func get_item_type(code_string: String) -> String:
	var type_code: String = all_codes[code_string]["type"] 
	return item_types[type_code]["ItemType"]

func get_item_tc(code_string: String) -> String:
	for tc: String in TREASURE_CLASS_ITEMS:
		if code_string in TREASURE_CLASS_ITEMS[tc]:
			return tc
	return ""

func get_item_class(code_string: String) -> D2Item.ClassSpecific:
	var item_type: String = all_codes[code_string]["type"] 
	var class_string: String = item_types[item_type]["Class"]
	return CLASS_ID_BY_CODE[class_string] as D2Item.ClassSpecific

func get_item_tier(code_string: String) -> D2Item.ItemTier:
	if all_codes[code_string]["normcode"] == code_string:
		return D2Item.ItemTier.NORMAL
	elif all_codes[code_string]["ubercode"] == code_string:
		return D2Item.ItemTier.EXCEPTIONAL
	else:
		return D2Item.ItemTier.ELITE

func get_weapon_damage_range(code_string: String, eth: bool) -> Dictionary:
	if not eth:
		return damage_ranges[code_string]["regular"]
	else:
		return damage_ranges[code_string]["eth"]

# ============================================================
# NAME GETTERS
# ============================================================

func get_item_unique_name(unique_id: int) -> String:
	return localize(unique_items[unique_id]["index"])

func get_item_set_name(set_id: int) -> String:
	return localize(set_items[set_id]["index"])

func get_item_runeword_name(rune_codes: Array[String]) -> String:
	for rw: String in runewords_parsed:
		if runewords_parsed[rw] == rune_codes:
			return localize(rw)
	return "Unknown Runeword"

func get_item_base_name(code_string: String) -> String:
	return localize(all_codes[code_string]["namestr"])

func get_item_dimensions(code_string: String) -> Vector2i:
	return Vector2i(int(all_codes[code_string]["invwidth"]), int(all_codes[code_string]["invheight"]))

func get_item_required_str(code_string: String) -> int:
	return int(all_codes[code_string].get("reqstr", 0))

func get_item_required_dex(code_string: String) -> int:
	return int(all_codes[code_string].get("reqdex", 0))

func get_item_required_level_from_affixes(prefix_ids: Array[int], suffix_ids: Array[int]) -> int:
	var max_required_level: int
	for prefix_id: int in prefix_ids:
		if prefix_id == 0:
			continue
		var required_level := int(magic_prefix[prefix_id - 1].get("levelreq", 0))
		if required_level > max_required_level:
			max_required_level = required_level
		if prefix_id == 451:
			pass
	for suffix_id: int in suffix_ids:
		if suffix_id == 0:
			continue
		var required_level := int(magic_suffix[suffix_id - 1].get("levelreq", 0))
		if required_level > max_required_level:
			max_required_level = required_level
	return max_required_level

func get_item_required_level(code_string: String) -> int:
	return int(all_codes[code_string].get("levelreq", 0))

func get_item_required_level_unique(unique_id: int) -> int:
	return int(unique_items[unique_id]["lvl req"])

func get_item_required_level_set(set_id: int) -> int:
	return int(set_items[set_id]["lvl req"])

func get_item_magic_name(code_string: String, prefix_id: int, suffix_id: int) -> String:
	var magic_name = ""
	var prefix = get_magic_prefix_name(prefix_id)
	var suffix = get_magic_suffix_name(suffix_id)
	if prefix != "":
		magic_name += prefix + " "
	magic_name += get_item_base_name(code_string)
	if suffix != "":
		magic_name += " " + suffix
	return magic_name

func get_item_rare_name(first_name_id: int, second_name_id: int) -> String:
	var prefix_str = rare_prefix[first_name_id - rare_suffix.size() - 1]["name"]
	prefix_str = localize(prefix_str)
	var suffix_str = rare_suffix[second_name_id - 1]["name"]
	suffix_str = localize(suffix_str)
	return prefix_str + " " + suffix_str.capitalize()

func get_magic_prefix_name(prefix_id: int) -> String:
	if prefix_id <= 0:
		return ""
	return localize(magic_prefix[prefix_id - 1]["Name"])

func get_magic_suffix_name(suffix_id: int) -> String:
	if suffix_id <= 0:
		return ""
	return localize(magic_suffix[suffix_id - 1]["Name"])


# ============================================================
# STAT COSTS
# ============================================================
func get_dgrp_required_count(dgrp: int) -> int:
	return DGRPS[dgrp].count


func get_dgrp_merged_stat_id(dgrp: int) -> int:
	return DGRPS[dgrp].id


func get_mgrp_merged_stat_id(mgrp: int) -> int:
	return MGRPS[mgrp]


func get_item_stat_cost(stat_id: int) -> Dictionary:
	if not item_stat_cost.has(stat_id):
		return {}
	return stat_cost_parsed[stat_id]

# ============================================================
# LOCALIZATION
# ============================================================

func localize(key: String) -> String:
	if localization_table.has(key):
		return localization_table[key]["Text"]
	return key

func get_skill_name(skill_id: int) -> String: #TODO return str name from skill_desc
	var skill_desc_id: String = skill_table[str(skill_id)]["skilldesc"]
	var desc_id: Dictionary = skill_desc.get(skill_desc_id, {})
	if desc_id:
		return skill_desc[skill_desc_id]["str name"]
	else:
		return ""

func get_skill_class_id(skill_id: int) -> int:
	var class_code: String = skill_table[str(skill_id)]["charclass"]
	return CLASS_ID_BY_CODE[class_code]

func get_charstat_class_all_skills_string(class_id: int) -> String:
	return charstat_table[class_id]["StrAllSkills"]

func get_charstat_class_tab_skills_string(packed_id: int) -> String:
	var class_id: int = floor(packed_id / 8)
	var tab_id: int = packed_id % 8 + 1
	
	var col_index: String = "StrSkillTab%d" % tab_id
	return charstat_table[class_id][col_index]

func get_charstat_class_only_string(class_id: int) -> String:
	return charstat_table[class_id]["StrClassOnly"]

func get_charstat_string(key: String) -> String:
	if charstat_table.has(key):
		return charstat_table[key]["Name"]
	return key

func get_monster_name(monster_id: int) -> String:
	if monster_table.has(monster_id):
		return localize(monster_table[monster_id]["NameStr"])
	return ""

# ============================================================
# CSV LOADER
# ============================================================

func _load_csv_as_dict(path: String, key_header: String = "", keep_columns: Array[String] = [], skip_expansion: bool = false) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	var headers := file.get_csv_line("\t")
	var result := {}

	var key_index := 0
	if key_header != "":
		key_index = headers.find(key_header)
		if key_index == -1:
			key_index = 0

	var row_number := 0
	var keep_set := {}
	for col: String in keep_columns:
		keep_set[col] = true

	while file.get_position() < file.get_length():
		var values := file.get_csv_line("\t")
		if values.size() == 0:
			continue

		if skip_expansion and values.size() > 0:
			if values[0] == "Expansion":
				continue

		var key: Variant
		if key_header != "":
			if key_index < values.size() and values[key_index] != "":
				key = values[key_index]
			else:
				key = row_number
		else:
			key = row_number

		var row := {}
		for i: int in headers.size():
			if keep_columns.size() == 0 or headers[i] in keep_set:
				if i < values.size():
					row[headers[i]] = values[i]
				else:
					row[headers[i]] = ""
		result[key] = row
		row_number += 1

	return result
