extends Node
## Read-only project boundary for static perk and active skill definitions.
## Mirrors the WorldLocations pattern: preload .tres content, register once,
## expose lookups. Static content never belongs to GameSession.

const HULL_PLATING: PerkDefinition = preload("res://data/perks/hull_plating.tres")
const FUEL_ECONOMIZER: PerkDefinition = preload(
	"res://data/perks/fuel_economizer.tres"
)
const WEAPON_CALIBRATION: PerkDefinition = preload(
	"res://data/perks/weapon_calibration.tres"
)
const CARGO_RACKS: PerkDefinition = preload("res://data/perks/cargo_racks.tres")
const VITALITY: PerkDefinition = preload("res://data/perks/vitality.tres")
const FIELD_REPAIR: PerkDefinition = preload("res://data/perks/field_repair.tres")
const STEADY_HANDS: PerkDefinition = preload("res://data/perks/steady_hands.tres")
const LIGHT_STEP: PerkDefinition = preload("res://data/perks/light_step.tres")

const AFTERBURNER: ActiveSkillDefinition = preload(
	"res://data/active_skills/afterburner.tres"
)
const NAPALM_BLAST: ActiveSkillDefinition = preload(
	"res://data/active_skills/napalm_blast.tres"
)
const DASH: ActiveSkillDefinition = preload("res://data/active_skills/dash.tres")
const ADRENALINE: ActiveSkillDefinition = preload(
	"res://data/active_skills/adrenaline.tres"
)

var _registry: SkillRegistry = SkillRegistry.new()


func _ready() -> void:
	_registry.register_perk(HULL_PLATING)
	_registry.register_perk(FUEL_ECONOMIZER)
	_registry.register_perk(WEAPON_CALIBRATION)
	_registry.register_perk(CARGO_RACKS)
	_registry.register_perk(VITALITY)
	_registry.register_perk(FIELD_REPAIR)
	_registry.register_perk(STEADY_HANDS)
	_registry.register_perk(LIGHT_STEP)

	_registry.register_active_skill(AFTERBURNER)
	_registry.register_active_skill(NAPALM_BLAST)
	_registry.register_active_skill(DASH)
	_registry.register_active_skill(ADRENALINE)


func has_perk(perk_id: StringName) -> bool:
	return _registry.has_perk(perk_id)


func find_perk(perk_id: StringName) -> PerkDefinition:
	return _registry.find_perk(perk_id)


func require_perk(perk_id: StringName) -> PerkDefinition:
	return _registry.require_perk(perk_id)


func get_all_perks() -> Array[PerkDefinition]:
	return _registry.get_all_perks()


func get_perks_by_branch(branch: SkillBranch.Type) -> Array[PerkDefinition]:
	return _registry.get_perks_by_branch(branch)


func has_active_skill(skill_id: StringName) -> bool:
	return _registry.has_active_skill(skill_id)


func find_active_skill(skill_id: StringName) -> ActiveSkillDefinition:
	return _registry.find_active_skill(skill_id)


func require_active_skill(skill_id: StringName) -> ActiveSkillDefinition:
	return _registry.require_active_skill(skill_id)


func get_all_active_skills() -> Array[ActiveSkillDefinition]:
	return _registry.get_all_active_skills()


func get_active_skills_by_branch(
	branch: SkillBranch.Type
) -> Array[ActiveSkillDefinition]:
	return _registry.get_active_skills_by_branch(branch)
