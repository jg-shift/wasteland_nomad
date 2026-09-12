# Skills: Passive Perks and Active Skills

Normative architecture for the progression system. Design sources: obsidian
notes `14 — Пассивные перки (демо)` (one-shot passive perks) and
`15 — Активные навыки (демо)` (pre-flight selectable active skills).

## Layering

```
data/perks/*.tres, data/active_skills/*.tres   (static content)
        |
domain/skills/    PerkDefinition, PerkEffect, ActiveSkillDefinition,
                  SkillBranch, SkillRegistry        (pure models)
        |
autoload/SkillCatalog.gd                           (read-only content boundary)
        |
application/skills/  PerkPurchaseService, PerkEffectApplier,
                     ActiveSkillLoadoutService      (orchestration)
        |
GameSession.profile (ProfileState)                  (campaign ownership)
        |
modes/*/controllers                                 (scene runtime)
```

Dependencies point downward only. `GameState` is not involved: consumers use
`GameSession.profile` (narrowest state model rule).

## Ownership and persistence

- `ProfileState.acquired_perk_ids` is the only record of perk ownership.
- `ProfileState.set_selected_active_skill(branch, id)` stores the loadout
  choice (one skill per branch, chosen in the hub before departure).
- Cooldowns and timed effects are scene runtime (`FlightActiveSkillController`),
  never session state and never saved.
- Save/load contract: load populates the profile, then
  `PerkEffectApplier.reapply_all(profile)` restores model effects
  deterministically onto fresh `GameSession` models.

## Effects are data, one interpreter

A perk carries `effects: Array[PerkEffect]`; each effect is
`{stat: StringName, operation: ADD|SCALE, value: float}`.
`application/skills/perk_effect_applier.gd` is THE single mapping point from
stats to session model mutators (push-style: models = base + applied perks).

| Stat | Operation | Target |
| --- | --- | --- |
| `craft_max_hp` | ADD | `GameSession.craft.health.add_max_hp` |
| `fuel_burn` | SCALE | `craft.fuel_tank.set_gallons_per_map_unit(BASE * value)`, BASE = 0.5 |
| `craft_weapon_damage_steps` | ADD | `craft.upgrades.add_weapon_damage_upgrade` |
| `pilot_max_hp` | ADD | `player.health.add_max_hp` |
| `cargo_capacity`, `pilot_weapon_damage_steps`, `pilot_move_speed`, `repair_speed` | — | no consumer yet (`push_warning`) |

SCALE on `fuel_burn` always computes from the BASE constant, never from the
current tank rate — this keeps `reapply_all` deterministic. Journeys snapshot
their rate at creation, so buying a perk mid-journey does not mutate an
in-flight journey.

### Extension rules

- New perk / active skill = a new `.tres` in `data/` + registration in
  `autoload/SkillCatalog.gd` (mirrors the location pattern:
  `LocationDefinition` → `LocationRegistry` → `WorldLocations`).
- New effect = a new `PerkEffect.STAT_*` id + one `match` branch in
  `PerkEffectApplier`. Nothing else changes.
- New active behavior = a new `kind` constant in `ActiveSkillDefinition` +
  a consumer in the owning mode controller. Definitions never contain code.
- A future move to pull-style derived stats replaces only
  `PerkEffectApplier`; definitions, registry, profile ownership, and services
  stay as they are.

## Active skill runtime

`ActiveSkillDefinition.kind` is the behavior key
(`afterburner`, `napalm_blast`, `dash`, `adrenaline`).

`modes/flight/controllers/flight_active_skill_controller.gd` (wired in
`flight.tscn`) reads the CRAFT selection at `_ready`, handles the
`active_skill` input action (Shift; Space is taken by `fire`), runs the
cooldown/effect timers, and emits `skill_activated(definition)`.
Afterburner applies a temporary `WorldUtils.set_flight_boost_multiplier`
(independent of `flight_speed_multiplier`, which `FlightSettings` rewrites
every frame) and resets the boost on `_exit_tree`.

Branch/mode separation is a design invariant: flight mode activates the craft
skill, walk mode will activate the pilot skill. One button per situation.

## Purchase flow

`PerkPurchaseService.purchase(perk_id)`:
catalog lookup → duplicate guard → `cost_credits` check against
`ProfileState.get_currency()` → deduct → `profile.acquire_perk` →
`PerkEffectApplier.apply`. `cost_items` is reserved and ignored (with a
warning) until the inventory system exists; the demo pays in credits only.
The hub workshop-robot UI is a thin caller of this service.

## Known scaffolding (not wired yet)

- Pilot-branch stats (`pilot_move_speed`, `pilot_weapon_damage_steps`,
  `repair_speed`, `cargo_capacity`) apply with a warning: walk mode, combat
  layer, and cargo have no consumers yet.
- `napalm_blast` emits `skill_activated` only; the cone-damage combat consumer
  is pending.
- Hub UI (purchase / loadout selection via the messenger) is pending —
  `HubScreenNavigator` is not instantiated by any scene.
- Walk-mode active skill controller (`dash`, `adrenaline`) arrives with the
  walk vertical slice.

## Verification

```bash
godot --path . --headless res://tools/verify_skills.tscn
```

Contracts covered: catalog registration and validity, purchase flow
(deduction, effects, duplicate/insufficient-funds rejection), `reapply_all`
restoration, loadout selection validation (branch mismatch, unknown id),
controller activation gating and boost math. Writes `.godot/skills_test.ok`.
