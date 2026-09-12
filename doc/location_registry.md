# Location Registry

## Purpose

The location registry is the read-only catalog of places that exist in the
world. It gives gameplay and UI systems one reliable source for:

- Stable location IDs
- Player-facing names
- Abstract world-map coordinates
- Location types
- Whether a location can be selected as a travel destination
- The scene containing that location's content

Static location definitions do not belong to `GameSession`. They describe the
game world and are shared by every campaign.

## State boundary

```text
WorldLocations                       GameSession.profile
      |                                      |
      v                                      v
LocationDefinition IDs <---------- discovered location IDs
      |
      v
Interactive map destinations
```

`WorldLocations` answers what exists. `ProfileState` answers what the current
player knows. The interactive map combines both.

This separation prevents a save file from duplicating coordinates, names, and
scene paths. A save only needs stable location IDs.

## Components

### LocationDefinition

Each definition is a Godot `Resource` with:

```gdscript
@export var location_id: StringName
@export var display_name: String
@export var map_coordinates: Vector2
@export var location_type: LocationType
@export var is_travel_destination: bool
@export var content_scene: PackedScene
```

Definitions should be treated as immutable at runtime. Campaign changes belong
to a separate state model keyed by `location_id`.

### LocationRegistry

`LocationRegistry` contains the reusable lookup and filtering behavior. It:

- Rejects invalid and duplicate IDs
- Preserves deterministic registration order
- Finds locations by ID
- Filters locations by type
- Returns discovered, selectable destinations

It does not access `GameSession`, calculate travel cost, or load scenes.

### WorldLocations

`WorldLocations` is the project-wide autoload boundary. It creates the registry
and registers the game's `.tres` location assets.

Systems should normally query this boundary:

```gdscript
var destination := WorldLocations.require_location(&"first_hub")
```

The underlying registry remains private so ordinary gameplay cannot
accidentally register or replace definitions.

## Initial locations

### Prologue Origin

```text
ID:                 prologue_origin
Coordinates:        (-20, 0)
Type:               SPECIAL
Travel destination: no
```

This hidden location anchors the opening journey without exposing it on the
interactive map.

### First Hub

```text
ID:                 first_hub
Coordinates:        (0, 0)
Type:               HUB
Travel destination: yes
```

The coordinate is the initial origin of the world map. More hubs can be placed
relative to it without using screen pixels.

### Tutorial Crash Site

```text
ID:                 tutorial_crash_site
Coordinates:        (-10, 0)
Type:               CRASH_SITE
Travel destination: no
```

It is a story location used by the opening crash sequence. It can be the
current location and journey origin, but the player cannot select it as a
normal destination.

The coordinates are provisional balancing data and can be changed in the
resource without changing gameplay code or save identifiers.

## Map query

The map gets discovered IDs from the session and definitions from the world
catalog:

```gdscript
var destinations := WorldLocations.get_available_destinations(
	GameSession.profile.get_discovered_location_ids(),
	GameSession.current_location_id
)
```

This query excludes:

- The current origin
- Undiscovered locations
- Locations marked as non-destinations

Reachability is a separate concern. For every returned destination, the map
uses `TravelCostCalculator` and the craft's `FuelTankState` to show distance,
required gallons, and whether the route can be started.

## Adding a location

1. Create the location content scene.
2. Create a `LocationDefinition` `.tres` file under `data/locations/`.
3. Give it a permanent, unique `location_id`.
4. Assign map coordinates and destination rules.
5. Register the resource in `WorldLocations`.
6. Add the ID to progression logic when the player discovers it.

Renaming display text is safe. Changing an ID after release requires save-data
migration.

## Architectural rules

- Scenes never serve as location identity.
- Map pixel positions never serve as world coordinates.
- Saves store IDs, not duplicated definitions.
- Crash sites may be registered while remaining non-selectable.
- `GameSession` does not own or mutate the registry.
- `LocationRegistry` does not decide which scene should be opened.
- `SceneRouter` or a future travel-flow coordinator performs transitions.

## Next step

The next slice is a map-facing route preview model. It should combine:

- Current location definition
- Candidate destination definition
- Calculated distance
- Required gallons
- Current-fuel reachability
- Tank-capacity reachability

After that model is stable, the interactive map scene can present destinations
without containing travel calculations.
