class_name ItemPropertyFormatter


static func format_properties(props: Array[Dictionary]) -> Array[String]:
	# 1) Merge properties
	var processed_props: Array[Dictionary] = _process_groups(props)

	# 2) Format
	var formatted_entries: Array[Dictionary]
	for i: int in processed_props.size():
		var prop: Dictionary = processed_props[i]
		var stat: Dictionary = TxtDB.get_item_stat_cost(prop.stat_id)
		if stat.descfunc == 0:
			continue

		var property_string: String = _format_property(prop.params, stat)
		if property_string == "":
			continue

		formatted_entries.append({
			"text": property_string,
			"priority": stat.descpriority,
			"index": i # sort by parse index when priority is tied
		})

	# 3) Sort
	formatted_entries.sort_custom(func(a: Dictionary, b: Dictionary):
		if a.priority == b.priority:
			return a.index < b.index
		return a.priority > b.priority
	)
	
	var formatted_properties: Array[String]
	for e: Dictionary in formatted_entries:
		formatted_properties.append(e.text)

	return formatted_properties

# ============================================================
# MERGE PROPERTIES
# ============================================================

static func _process_groups(props: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary]

	var by_dgrp: Dictionary[int, Array]
	var by_mgrp: Dictionary[int, Array]
	var no_group: Array[Dictionary]

	# Partition properties
	for p: Dictionary in props:
		var stat: Dictionary = TxtDB.get_item_stat_cost(p.stat_id)
		if stat.dgrp != 0:
			if not by_dgrp.has(stat.dgrp):
				by_dgrp[stat.dgrp] = []
			by_dgrp[stat.dgrp].append(p)
		elif stat.mgrp != 0:
			if not by_mgrp.has(stat.mgrp):
				by_mgrp[stat.mgrp] = []
			by_mgrp[stat.mgrp].append(p)
		else:
			no_group.append(p)
			continue

	# Process each dgrp
	for dgrp: int in by_dgrp:
		var group: Array = by_dgrp[dgrp]
		if _can_merge_dgrp(dgrp, group):
			result.append(_merge_dgrp(dgrp, group))
		else:
			result.append_array(group)
	
	# Process each mgrp
	for mgrp: int in by_mgrp:
		var group: Array = by_mgrp[mgrp]
		if group.size() >= 2:
			result.append(_merge_mgrp(mgrp, group))
		else:
			result.append_array(group)
	
	# Add ungrouped props
	result.append_array(no_group)

	return result


static func _can_merge_dgrp(dgrp: int, group: Array) -> bool:
	# 1. Required count check
	var required: int = TxtDB.get_dgrp_required_count(dgrp)
	if group.size() != required:
		return false

	# 2. All params[0] must match
	var value: int = group[0].params[0]
	for p: Dictionary in group:
		if p.params[0] != value:
			return false

	return true


static func _merge_dgrp(dgrp: int, group: Array) -> Dictionary:
	var merged_stat_id: int = TxtDB.get_dgrp_merged_stat_id(dgrp)
	var value: int = group[0].params[0]

	return {
		"stat_id": merged_stat_id,
		"params": [value],
	}


static func _merge_mgrp(mgrp: int, group: Array) -> Dictionary:
	var merged_stat_id: int = TxtDB.get_mgrp_merged_stat_id(mgrp)
	var values: Array[int]
	for p: Dictionary in group:
		values.append(p.params[0])

	return {
		"stat_id": merged_stat_id,
		"params": values,
	}

# ============================================================
# CORE FORMAT
# ============================================================

static func _format_property(params: Array, stat: Dictionary) -> String:
	var value: int = params.back()
	var string: String
	if value < 0 and stat.descstrneg != "":
		string = TxtDB.localize(stat.descstrneg)
	else:
		string = TxtDB.localize(stat.descstrpos)
	
	# ============================================================
	# DESCFUNC
	# ============================================================

	match stat.descfunc:
		0: # No display
			return ""

		1: # Plus or minus
			var value_string: String = "+%d" % value if value > 0 else "%d" % value
			return _format_with_descvalue(value_string, string, stat.descval)
		
		2: # Percent
			var value_string: String = "%d%%" % value
			return _format_with_descvalue(value_string, string, stat.descval)

		3: # String
			var value_string: String = "%d" % value
			return _format_with_descvalue(value_string, string, stat.descval)

		4: # Plus percent
			var value_string: String = "+%d%%" % value if value > 0 else "%d%%" % value
			return _format_with_descvalue(value_string, string, stat.descval)

		5: # Percent 128
			var value_string: String = "+%d%%" % (value * 100 / 128)
			return _format_with_descvalue(value_string, string, stat.descval)

		6: # Plus or minus per level
			var value_string: String = "+%d" % value if value > 0 else "%d" % value
			#var property_string: String = "%s %s" % [string, TxtDB.localize(stat.descstr2)]
			#return _format_with_descvalue(value_string, property_string, stat.descval)
			var intermediate_string: String = _format_with_descvalue(value_string, string, stat.descval)
			return "%s %s" % [intermediate_string, TxtDB.localize(stat.descstr2)]

		7: # Percent per level
			var value_string: String = "%d%%" % value
			#var property_string: String = "%s %s" % [string, TxtDB.localize(stat.descstr2)]
			#return _format_with_descvalue(value_string, property_string, stat.descval)
			var intermediate_string: String = _format_with_descvalue(value_string, string, stat.descval)
			return "%s %s" % [intermediate_string, TxtDB.localize(stat.descstr2)]

		8: # Plus percent per level
			var value_string: String = "+%d%%" % value if value > 0 else "%d%%" % value
			#var property_string: String = "%s %s" % [string, TxtDB.localize(stat.descstr2)]
			#return _format_with_descvalue(value_string, property_string, stat.descval)
			var intermediate_string: String = _format_with_descvalue(value_string, string, stat.descval)
			return "%s %s" % [intermediate_string, TxtDB.localize(stat.descstr2)]

		9: # String per level
			var value_string: String = "%d" % value
			var intermediate_string: String = _format_with_descvalue(value_string, string, stat.descval)
			return "%s %s" % [intermediate_string, TxtDB.localize(stat.descstr2)]

		10: # Percent 128 per level
			var value_string: String = "%d%%" % (value * 100 / 128)
			var intermediate_string: String = _format_with_descvalue(value_string, string, stat.descval)
			return "%s %s" % [intermediate_string, TxtDB.localize(stat.descstr2)]

		11: # Repairs durability. Fix to use ModStre9u
			return string % (100 / value)

		12: # Plus sub one
			var value_string: String = "+%d" % value if value > 1 else "%d" % value
			return _format_with_descvalue(value_string, string, stat.descval)

		13: # Add class skill
			var property_string: String = TxtDB.get_charstat_class_all_skills_string(params[0])
			var output: String = "+%d %s" % [params[1], TxtDB.localize(property_string)]
			return output

		14: # Add tab skill
			var class_tab_skills_string: String = TxtDB.get_charstat_class_tab_skills_string(params[0])
			var class_only_string: String = TxtDB.get_charstat_class_only_string(floor(params[0] / 8))
			var output: String = "%s %s" % [TxtDB.localize(class_tab_skills_string), TxtDB.localize(class_only_string)] % params[1]
			return "%s %s" % [TxtDB.localize(class_tab_skills_string), TxtDB.localize(class_only_string)] % params[1]

		15: # Proc skill
			var skill_name: String = TxtDB.localize(TxtDB.get_skill_name(params[1]))
			if skill_name != "":
				return string % [params[2], params[0], skill_name]
			else:
				return string

		16: # Aura
			var skill_name: String = TxtDB.localize(TxtDB.get_skill_name(params[0]))
			return string % [params[1], skill_name]

		17, 18: # By time
			return "Stat By Time (not implemented)"

		19: # Sprintf num / Enhanced damage
			return string % value

		20: # Minus percent
			var value_string: String = "%d%%" % (value * -1)
			return _format_with_descvalue(value_string, string, stat.descval)

		21: # Minus percent per level
			return "Minus percent per level (not implemented)"

		22: # Versus monsters percent
			return "Versus monsters percent (not implemented)"

		23: # Reanimates
			var monster_string := TxtDB.get_monster_name(params[0])
			return "%s%% %s %s" % [params[1], string, monster_string]

		24: # Charges
			# param[0] = skill level
			# param[1] = skill id
			# param[2] = current charges
			# param[3] = max charges
			var skill_string: String = TxtDB.localize(TxtDB.get_skill_name(params[1]))
			return "Level %d %s %s" % [value, skill_string, string] % [params[2], params[3]]

		25: # Minus
			return "Minus (not implemented)"

		26: # Minus
			return "Minus (not implemented)"

		27: # Single skill
			var skill: String = TxtDB.get_skill_name(params[0])
			var class_id: int = TxtDB.get_skill_class_id(params[0])
			var class_only_string = TxtDB.get_charstat_class_only_string(class_id)
			var output: String = "+%d to %s %s" % [params[1], TxtDB.localize(skill), TxtDB.localize(class_only_string)]
			return output

		28: # OSkill
			# param[0] = skill id
			# param[1] = skill level
			var skill_string: String = TxtDB.localize(TxtDB.get_skill_name(params[0]))
			return "+%d to %s" % [params[1], skill_string]

		29: # Sprintf num positive
			return "Sprintf positive (not implemented)"

		101: # Damage range
			return string % [params[0], params[1]]

		102: # Poison damage
			return string % [params[0] * 25/128, params[2] * 1/25]

		_:
			return "Unknown descfunc"


# ============================================================
# HELPERS
# ============================================================

static func _format_with_descvalue(value_string: String, property_string: String, descvalue: int) -> String:
	match descvalue:
		0:
			return property_string
		1:
			return "%s %s" % [value_string, property_string]
		2:
			return "%s %s" % [property_string, value_string]
		_:
			return ""
