class_name D2Colors

const COLOR_MAGIC: Color = Color("#4169E1")
const COLOR_RARE: Color = Color("#FFFF00")
const COLOR_CRAFTED: Color = Color("#FF8C00")
const COLOR_SET: Color = Color("#00FF00")
const COLOR_UNIQUE: Color = Color("#C7B377")
const COLOR_CORRUPTED: Color = Color("ff334eff")
const COLOR_GRAY: Color = Color.DIM_GRAY
const COLOR_PURPLE: Color = Color("6e28b8ff")

static var orange_item_codes: Array[String]
static var gold_item_codes: Array[String]
static var purple_item_codes: Array[String]
static var red_item_codes: Array[String]


static func get_item_color(item: D2Item) -> Color:
	match item.rarity:
		D2Item.ItemRarity.MAGIC:
			return COLOR_MAGIC
		D2Item.ItemRarity.RARE:
			return COLOR_RARE
		D2Item.ItemRarity.CRAFTED:
			return COLOR_CRAFTED
		D2Item.ItemRarity.SET:
			return COLOR_SET
		D2Item.ItemRarity.UNIQUE:
			return COLOR_UNIQUE
		_:
			if item.has_runeword:
				return COLOR_UNIQUE
			elif item.is_ethereal or item.total_sockets > 0:
				return COLOR_GRAY
			elif item.is_misc:
				if item.is_rune:
					return COLOR_CRAFTED
				var item_code := item.code_string
				if item_code in orange_item_codes:
					return COLOR_CRAFTED
				elif item_code in gold_item_codes:
					return COLOR_UNIQUE
				elif item_code in red_item_codes:
					return COLOR_CORRUPTED
				elif item_code in purple_item_codes:
					return COLOR_PURPLE
				else:
					return Color.WHITE
			else:
				return Color.WHITE


class ColorGenerator:
	const SATURATION := 0.3
	const VALUE := 0.95
	const ITEM_COUNT := 50
	const HUE_STEP := 1.0 / ITEM_COUNT
	const ALPHA = 0.9
	
	var hue := 0.0

	func next_color() -> Color:
		var color := Color.from_hsv(hue, SATURATION, VALUE, ALPHA)
		hue = fmod(hue + HUE_STEP, 1.0)
		return color
