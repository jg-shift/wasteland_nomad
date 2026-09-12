extends RefCounted
class_name ActiveSkillLoadoutService
## Pre-flight loadout selection for active skills (design: obsidian note 15).
## One selected skill per branch; the choice is made in the hub planning
## screen and persists in ProfileState until changed.


static func select(branch: SkillBranch.Type, skill_id: StringName) -> bool:
	var definition := SkillCatalog.find_active_skill(skill_id)
	if definition == null:
		push_error(
			"ActiveSkillLoadoutService: unknown active skill '%s'" % skill_id
		)
		return false
	if definition.branch != branch:
		push_error(
			"ActiveSkillLoadoutService: skill '%s' belongs to another branch"
			% skill_id
		)
		return false

	GameSession.profile.set_selected_active_skill(branch, skill_id)
	return true


static func get_selected_definition(
	branch: SkillBranch.Type
) -> ActiveSkillDefinition:
	var skill_id := GameSession.profile.get_selected_active_skill(branch)
	if skill_id.is_empty():
		return null
	return SkillCatalog.find_active_skill(skill_id)
