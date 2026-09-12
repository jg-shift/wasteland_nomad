extends RefCounted
class_name PerkEffectApplier
## THE single mapping point from declarative PerkEffect data to GameSession
## model mutators. Push-style: models always equal base state + applied perks.
##
## Rules:
## - Adding a new effect = new PerkEffect.STAT_* id + one match branch here.
## - Stats without a consumer yet log a warning (honest scaffolding).
## - reapply_all() is the save-load contract: fresh models from
##   GameSession.initialize_new_game() + acquired perk ids => deterministic
##   restoration. Save/load wiring will call it after populating the profile.

## Base fuel burn rate — the FuelTankState._init default. SCALE effects on
## fuel_burn always compute from this base, never from the current tank
## value, so reapplication is deterministic.
const BASE_GALLONS_PER_MAP_UNIT := 0.5


static func apply(definition: PerkDefinition) -> void:
	if definition == null or not definition.is_valid():
		push_error("PerkEffectApplier: definition is null or invalid")
		return
	for effect in definition.effects:
		_apply_effect(effect)


static func reapply_all(profile: ProfileState) -> void:
	if profile == null:
		push_error("PerkEffectApplier: profile is null")
		return
	for perk_id in profile.acquired_perk_ids:
		var definition := SkillCatalog.find_perk(perk_id)
		if definition == null:
			push_warning(
				"PerkEffectApplier: unknown perk '%s' in profile" % perk_id
			)
			continue
		apply(definition)


static func _apply_effect(effect: PerkEffect) -> void:
	if effect == null or not effect.is_valid():
		push_error("PerkEffectApplier: effect is null or invalid")
		return

	match effect.stat:
		PerkEffect.STAT_CRAFT_MAX_HP:
			if effect.operation == PerkEffect.Operation.ADD:
				GameSession.craft.health.add_max_hp(int(effect.value))
			else:
				_warn_unsupported(effect)
		PerkEffect.STAT_FUEL_BURN:
			if effect.operation == PerkEffect.Operation.SCALE:
				GameSession.craft.fuel_tank.set_gallons_per_map_unit(
					BASE_GALLONS_PER_MAP_UNIT * effect.value
				)
			else:
				_warn_unsupported(effect)
		PerkEffect.STAT_CRAFT_WEAPON_DAMAGE_STEPS:
			if effect.operation == PerkEffect.Operation.ADD:
				GameSession.craft.upgrades.add_weapon_damage_upgrade(
					int(effect.value)
				)
			else:
				_warn_unsupported(effect)
		PerkEffect.STAT_PILOT_MAX_HP:
			if effect.operation == PerkEffect.Operation.ADD:
				GameSession.player.health.add_max_hp(int(effect.value))
			else:
				_warn_unsupported(effect)
		PerkEffect.STAT_CARGO_CAPACITY, \
		PerkEffect.STAT_PILOT_WEAPON_DAMAGE_STEPS, \
		PerkEffect.STAT_PILOT_MOVE_SPEED, \
		PerkEffect.STAT_REPAIR_SPEED:
			push_warning(
				"PerkEffectApplier: stat '%s' has no consumer yet"
				% effect.stat
			)
		_:
			push_warning(
				"PerkEffectApplier: unknown stat '%s'" % effect.stat
			)


static func _warn_unsupported(effect: PerkEffect) -> void:
	push_warning(
		"PerkEffectApplier: operation %d is not supported for stat '%s'"
		% [effect.operation, effect.stat]
	)
