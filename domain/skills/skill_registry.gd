extends RefCounted
class_name SkillRegistry
## In-memory registry of static perk and active skill definitions.
## Mirrors the LocationRegistry pattern: insertion order is preserved,
## IDs are unique, duplicates and invalid resources are rejected.

signal perk_registered(definition: PerkDefinition)
signal active_skill_registered(definition: ActiveSkillDefinition)

var _perks_by_id: Dictionary = {}
var _perk_order: Array[StringName] = []
var _active_skills_by_id: Dictionary = {}
var _active_skill_order: Array[StringName] = []


func register_perk(definition: PerkDefinition) -> bool:
	if definition == null or not definition.is_valid():
		push_error("SkillRegistry: perk definition is invalid")
		return false
	if _perks_by_id.has(definition.perk_id):
		push_error(
			"SkillRegistry: duplicate perk ID '%s'" % definition.perk_id
		)
		return false

	_perks_by_id[definition.perk_id] = definition
	_perk_order.append(definition.perk_id)
	perk_registered.emit(definition)
	return true


func register_active_skill(definition: ActiveSkillDefinition) -> bool:
	if definition == null or not definition.is_valid():
		push_error("SkillRegistry: active skill definition is invalid")
		return false
	if _active_skills_by_id.has(definition.skill_id):
		push_error(
			"SkillRegistry: duplicate active skill ID '%s'"
			% definition.skill_id
		)
		return false

	_active_skills_by_id[definition.skill_id] = definition
	_active_skill_order.append(definition.skill_id)
	active_skill_registered.emit(definition)
	return true


func has_perk(perk_id: StringName) -> bool:
	return _perks_by_id.has(perk_id)


func find_perk(perk_id: StringName) -> PerkDefinition:
	return _perks_by_id.get(perk_id) as PerkDefinition


func require_perk(perk_id: StringName) -> PerkDefinition:
	var definition := find_perk(perk_id)
	if definition == null:
		push_error("SkillRegistry: unknown perk ID '%s'" % perk_id)
	return definition


func has_active_skill(skill_id: StringName) -> bool:
	return _active_skills_by_id.has(skill_id)


func find_active_skill(skill_id: StringName) -> ActiveSkillDefinition:
	return _active_skills_by_id.get(skill_id) as ActiveSkillDefinition


func require_active_skill(skill_id: StringName) -> ActiveSkillDefinition:
	var definition := find_active_skill(skill_id)
	if definition == null:
		push_error(
			"SkillRegistry: unknown active skill ID '%s'" % skill_id
		)
	return definition


func get_all_perks() -> Array[PerkDefinition]:
	var result: Array[PerkDefinition] = []
	for perk_id in _perk_order:
		result.append(_perks_by_id[perk_id] as PerkDefinition)
	return result


func get_perks_by_branch(
	branch: SkillBranch.Type
) -> Array[PerkDefinition]:
	var result: Array[PerkDefinition] = []
	for definition in get_all_perks():
		if definition.branch == branch:
			result.append(definition)
	return result


func get_all_active_skills() -> Array[ActiveSkillDefinition]:
	var result: Array[ActiveSkillDefinition] = []
	for skill_id in _active_skill_order:
		result.append(_active_skills_by_id[skill_id] as ActiveSkillDefinition)
	return result


func get_active_skills_by_branch(
	branch: SkillBranch.Type
) -> Array[ActiveSkillDefinition]:
	var result: Array[ActiveSkillDefinition] = []
	for definition in get_all_active_skills():
		if definition.branch == branch:
			result.append(definition)
	return result
