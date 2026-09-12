extends Resource
class_name PerkEffect
## Declarative stat modifier carried by a PerkDefinition.
## Pure data: interpretation lives in exactly one place —
## application/skills/perk_effect_applier.gd (stat -> session model mutator).
## Adding a new effect = new STAT_* id + one match branch in the applier.

enum Operation {
	ADD,
	SCALE,
}

const STAT_CRAFT_MAX_HP := &"craft_max_hp"
const STAT_FUEL_BURN := &"fuel_burn"
const STAT_CRAFT_WEAPON_DAMAGE_STEPS := &"craft_weapon_damage_steps"
const STAT_CARGO_CAPACITY := &"cargo_capacity"
const STAT_PILOT_MAX_HP := &"pilot_max_hp"
const STAT_PILOT_WEAPON_DAMAGE_STEPS := &"pilot_weapon_damage_steps"
const STAT_PILOT_MOVE_SPEED := &"pilot_move_speed"
const STAT_REPAIR_SPEED := &"repair_speed"

@export var stat: StringName = &""
@export var operation: Operation = Operation.ADD
@export var value: float = 0.0


func _init(
	p_stat: StringName = &"",
	p_operation: Operation = Operation.ADD,
	p_value: float = 0.0
) -> void:
	stat = p_stat
	operation = p_operation
	value = p_value


func is_valid() -> bool:
	return not stat.is_empty()
