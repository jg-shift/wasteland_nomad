# Journey and Fuel Architecture

## Purpose

The journey domain connects the interactive map to Flight, crash recovery, and
arrival. It provides consistent distances between locations and uses gallons
of fuel as the maximum-range restriction.

Map coordinates are abstract floating-point world coordinates. They are not
screen pixels or real-world miles, but their relative distances are stable.

## Domain model

```text
LocationDefinition (origin) ----+
                                |
                                v
                       TravelCostCalculator
                                |
                                v
LocationDefinition (destination) --> JourneyState
                                         |
                                         v
                                  FuelTankState
```

### LocationDefinition

A `LocationDefinition` is static, authorable world data:

- Stable location ID
- Player-facing display name
- `Vector2` map coordinates
- Location type

It extends `Resource`, allowing locations to become `.tres` assets when the
world registry is implemented.

Location coordinates remain unchanged during a campaign. UI code converts
these coordinates to map pixels; it must not use pixel positions to calculate
travel distance.

### TravelCostCalculator

`TravelCostCalculator` is a stateless calculation service:

```text
distance = origin.distance_to(destination)
fuel required = distance * gallons per map unit
maximum distance = available gallons / gallons per map unit
```

It does not read `GameSession`, modify the craft, or control UI. Consequently,
map previews and gameplay use the same calculations without duplicating rules.

### FuelTankState

`FuelTankState` belongs to `CraftState` and owns:

- Current fuel in gallons
- Tank capacity in gallons
- Fuel consumption in gallons per map unit

Its initial balancing values are provisional:

- Capacity: `20.0` gallons
- Starting fuel: `20.0` gallons
- Consumption: `0.5` gallons per map unit

The tank validates refuelling, capacity changes, efficiency changes, and fuel
consumption. It never calculates routes or chooses destinations.

### JourneyState

`JourneyState` is the state of one trip. It snapshots:

- Origin and destination IDs
- Origin and destination coordinates
- Total and travelled distance
- Required and consumed fuel
- Gallons-per-map-unit rate used for this journey
- Flight seed
- Journey status

Snapshotting the coordinates and consumption rate prevents a journey already
in progress from changing if world data or craft upgrades are modified.

## Journey statuses

```text
PLANNED --> IN_FLIGHT --> COMPLETED
                |
                v
             CRASHED
                |
                +--------> IN_FLIGHT
```

- `PLANNED`: constructed but not accepted by `GameSession`
- `IN_FLIGHT`: active and allowed to advance
- `CRASHED`: retains progress but cannot advance
- `COMPLETED`: destination reached

A crash does not create a new journey. Repair resumes the existing
`JourneyState`.

## Starting restriction

`GameSession.begin_journey()` accepts a journey only when:

- No other journey is active
- Both endpoints are valid and different
- Distance is greater than zero
- The craft currently carries enough fuel for the complete remaining route
- The journey is still `PLANNED`

Tank capacity defines the craft's theoretical maximum range. Current fuel
determines which destinations can be selected now.

The map should show both conditions:

- Destination exceeds tank range
- Destination is within tank range but requires refuelling

## Incremental fuel use

Fuel is consumed by travelled distance instead of being removed at departure.

```gdscript
var travelled := GameSession.active_journey.advance(
	frame_distance,
	GameSession.craft.fuel_tank
)
```

`advance()`:

1. Requires the journey to be `IN_FLIGHT`.
2. Limits movement to the remaining journey distance.
3. Limits movement to the distance affordable with current fuel.
4. Consumes the matching gallons.
5. Updates travelled distance and consumed fuel.
6. Changes the status to `COMPLETED` at the destination.

This preserves accurate fuel and progress when Flight is interrupted by a
crash.

The existing Flight scene connects to this method through
[`FlightJourneyAdapter`](flight_journey_adapter.md), which converts normalized
Flight progress into absolute journey distance.

## GameSession ownership

`GameSession` owns at most one `active_journey`. Scene changes do not clear it.

```gdscript
var journey := JourneyState.new(
	origin,
	destination,
	GameSession.craft.fuel_tank.get_gallons_per_map_unit(),
	flight_seed
)

if GameSession.begin_journey(journey):
	SceneRouter.change_scene_to_file(SceneRouter.FLIGHT_SCENE)
```

The map creates the planned journey. Flight advances it. The crash workflow
changes its status. Arrival code observes completion, updates the current
location, and then clears the journey.

`GameSession` owns the state but does not change scenes, calculate routes, or
decide which destination the player selects.

## Next integration step

The next slice should connect these models to the game flow:

1. Create a map-facing route preview model.
2. Create the interactive map scene.
3. Preview distance, gallons, and reachability for each destination.
4. Start a journey after player confirmation.
5. Convert Flight progress into journey distance and incremental fuel use.
6. Preserve the journey when routing to a crash site.
7. Complete it on arrival and update `current_location_id`.
