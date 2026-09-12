# GameSession

## Purpose

`GameSession` owns the persistent runtime state of one loaded campaign.

The same session remains active while the player moves between:

- Flight scenes
- Walk scenes
- Crash sites and dungeons
- Hub scenes
- The interactive travel map

Changing a scene or entering another hub must not create a new `GameSession`.

## Lifetime

A session begins when a new game is created or a saved game is loaded. It ends
when the player returns to the main menu, loads another campaign, or explicitly
clears the current campaign.

```text
New game / Load game
          |
          v
     GameSession
          |
          +-- Flight
          +-- Crash site
          +-- Walk / Dungeon
          +-- Hub
          +-- Travel map
          |
          v
 Quit campaign / Load another game
```

`GameSession.initialize_new_game()` replaces all campaign state with fresh
models. `GameSession.clear_session()` removes the active campaign state.

## Owned state

### ProfileState

Campaign-wide progression that belongs to the player profile:

- Currency
- Discovered hub and location IDs
- Per-location state
- Prologue completion

Knowledge of a hub is persistent. Once its location is discovered, the travel
map can continue offering it as a destination.

### CraftState

Persistent hovercraft state:

- Craft health
- Craft upgrades
- Current fuel, tank capacity, and fuel consumption
- Installed weapon IDs

Damage and upgrades survive scene changes. A scene displays and modifies the
craft state; it does not own it.

### PlayerState

Persistent on-foot character state:

- Player health
- Equipped walking weapon IDs

The walking character scene is a presentation and control layer over this
state.

### ExpeditionState

Temporary state for the currently active expedition:

- Expedition identifier
- Expedition score
- Unsecured loot
- Temporary modifiers

Only one expedition can be active. It may continue across Flight, a crash, the
crash site, and resumed Flight. Entering a scene does not automatically end it.

### JourneyState

The active journey stores its endpoints, abstract world coordinates, distance,
fuel consumption, progress, flight seed, and status. It remains active through
Flight, a crash site, repairs, and resumed Flight.

Only one journey can be active. Its full design is described in
[`journey_and_fuel.md`](journey_and_fuel.md).

### Current location

`current_location_id` identifies the stable world location occupied by the
player. It is not the current scene path.

Examples:

- `first_hub`
- `crash_site_01`
- `wasteland_dungeon_03`

Scene paths are technical implementation details and must not be stored as
world-location identity.

## Responsibilities

`GameSession` may:

- Create fresh campaign state
- Hold campaign-owned models
- Replace all models when starting or loading a campaign
- Track the current world location
- Start and clear an expedition
- Start and clear a journey
- Notify observers when owned models are replaced

`GameSession` must not:

- Change scenes
- Decide the next game mode
- Process player input
- Spawn enemies
- Control UI
- Calculate travel routes
- Read or write save files directly
- Contain hub-specific behavior

These boundaries keep the session focused on state ownership.

## Relationship with GameState

`GameState` remains a compatibility facade for existing gameplay code.

Legacy calls such as:

```gdscript
GameState.take_craft_damage(10)
GameState.get_player_hp()
GameState.add_points(100)
```

continue to work, but the underlying persistent models now belong to
`GameSession`. Score calls target the active expedition when one exists and
otherwise use the legacy compatibility score.

```text
Existing gameplay code
          |
          v
      GameState
          |
          v
     GameSession
       /   |   \
 Profile Craft Player
```

New systems should use the narrowest suitable state model. They should not add
new persistent data to `GameState`.

## Model replacement

Starting a new game or loading a save replaces the profile, craft, and player
objects. Systems holding signal connections to old objects must reconnect.

`GameSession.state_models_replaced` announces this operation. `GameState`
already listens to it and reconnects its compatibility signals.

Prefer asking `GameSession` for the current model when needed instead of
storing a permanent reference:

```gdscript
func repair_craft(amount: int) -> void:
	GameSession.craft.health.heal(amount)
```

If a system must retain a model reference, it must listen for
`state_models_replaced`.

## Scene usage rules

A scene may:

- Read session state during setup
- Present session state through UI
- Send player actions to domain methods
- Subscribe to state-change signals

A scene must not:

- Recreate persistent state in `_ready()`
- Reset craft or player health merely because the scene loaded
- Store progression only inside scene nodes
- Treat a scene reload as a new campaign

Example:

```gdscript
func _ready() -> void:
	GameSession.craft.health.changed.connect(_on_craft_health_changed)
	_on_craft_health_changed(
		GameSession.craft.health.get_hp(),
		GameSession.craft.health.get_max_hp()
	)
```

## Hub behavior

Changing hubs changes `current_location_id` and the loaded hub scene or hub
configuration. It does not replace `GameSession`.

Hub-specific inventory, NPC state, and quest state should be stored under a
location-owned model or another dedicated campaign model. They should not be
implemented by creating a different session for every hub.

## Public lifecycle example

```gdscript
# Start a campaign.
GameSession.initialize_new_game()

# Arrive at the first hub.
GameSession.set_current_location(&"first_hub")
GameSession.profile.discover_location(&"first_hub")

# Begin an expedition.
var expedition := ExpeditionState.new(&"first_hub_supply_run")
GameSession.begin_expedition(expedition)

# Finish or abandon it.
GameSession.clear_expedition()

# Leave the campaign.
GameSession.clear_session()
```

## Future integration

Planned systems should interact with `GameSession` through dedicated models:

- Save repository: converts session models to and from save data
- `WorldLocations`: static definitions outside the session
- World progression: quests, NPC state, and persistent location changes

`GameSession` remains the owner and composition root for these campaign models,
not the system that performs all their behavior.
