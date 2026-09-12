extends Resource
class_name PerkDefinition
## Static definition of one purchasable passive perk (one-shot, no levels).
## Design source: obsidian note "14 — Пассивные перки (демо)".
## Content-only: lives in res://data/perks/*.tres, never mutated at runtime.

@export var perk_id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var branch: SkillBranch.Type = SkillBranch.Type.CRAFT
@export var cost_credits: int = 0
## Reserved for the future inventory system: item id -> amount.
@export var cost_items: Dictionary = {}
@export var effects: Array[PerkEffect] = []


func _init(
	p_perk_id: StringName = &"",
	p_display_name: String = "",
	p_branch: SkillBranch.Type = SkillBranch.Type.CRAFT,
	p_cost_credits: int = 0,
	p_effects: Array[PerkEffect] = []
) -> void:
	perk_id = p_perk_id
	display_name = p_display_name
	branch = p_branch
	cost_credits = p_cost_credits
	effects = p_effects


func is_valid() -> bool:
	if perk_id.is_empty() or cost_credits < 0:
		return false
	for effect in effects:
		if effect == null or not effect.is_valid():
			return false
	return true
