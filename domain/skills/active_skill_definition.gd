extends Resource
class_name ActiveSkillDefinition
## Static definition of one selectable active skill.
## Design source: obsidian note "15 — Активные навыки (демо)".
## `kind` is the behavior key: concrete runtime behavior lives in mode
## controllers (strategy by kind), never in this definition.

const KIND_AFTERBURNER := &"afterburner"
const KIND_NAPALM_BLAST := &"napalm_blast"
const KIND_DASH := &"dash"
const KIND_ADRENALINE := &"adrenaline"

@export var skill_id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var branch: SkillBranch.Type = SkillBranch.Type.CRAFT
@export var kind: StringName = &""
@export var duration_sec: float = 0.0
@export var cooldown_sec: float = 0.0


func _init(
	p_skill_id: StringName = &"",
	p_display_name: String = "",
	p_branch: SkillBranch.Type = SkillBranch.Type.CRAFT,
	p_kind: StringName = &"",
	p_duration_sec: float = 0.0,
	p_cooldown_sec: float = 0.0
) -> void:
	skill_id = p_skill_id
	display_name = p_display_name
	branch = p_branch
	kind = p_kind
	duration_sec = p_duration_sec
	cooldown_sec = p_cooldown_sec


func is_valid() -> bool:
	return (
		not skill_id.is_empty()
		and not kind.is_empty()
		and duration_sec >= 0.0
		and cooldown_sec > 0.0
	)
