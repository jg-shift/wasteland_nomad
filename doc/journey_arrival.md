# Journey Arrival

## Purpose

Successful Flight completion resolves the active journey into persistent
campaign progression before a destination scene is opened.

```text
Journey COMPLETED
        |
        v
JourneyArrivalService
        |
        +-- current location = destination
        +-- discover destination
        +-- complete applicable story progress
        +-- clear active journey
        |
        v
FlightFlowController
        |
        v
Destination shell
```

## JourneyArrivalService

`JourneyArrivalService.complete_active_journey()` requires:

- An active journey
- Journey status `COMPLETED`
- A destination registered in `WorldLocations`

It then:

1. Sets `GameSession.current_location_id`.
2. Adds the destination ID to `ProfileState` discoveries.
3. Completes the prologue when the prologue expedition reaches First Hub.
4. Clears the completed journey.
5. Returns the destination definition to the flow controller.

The active expedition is deliberately not cleared. Score and unsecured loot
must be settled by a dedicated Hub operation rather than silently discarded by
scene navigation.

## Flight flow

When Flight completes with an active journey, `FlightFlowController` invokes
the arrival service and selects a destination shell from the location type.

Hub destinations currently route through:

```gdscript
SceneRouter.open_hub()
```

Flight without an active journey continues using its configured legacy finish
scene.

## Dynamic Hub content

The Hub shell reads the current location ID from `GameSession`, finds its
definition in `WorldLocations`, and loads its `content_scene`.

```gdscript
var definition := WorldLocations.find_location(
	GameSession.current_location_id
)
load_location(definition.content_scene)
```

`initial_location` remains as an editor and migration fallback when the Hub
scene is run directly without campaign location state.

The Hub title is populated from the registered display name.

## Result of the tutorial journey

On successful arrival:

```text
Current location:  first_hub
First Hub:         discovered
Prologue:          completed
Active journey:    none
Active expedition: prologue (awaiting settlement)
Craft fuel:        10 gallons with provisional values
```

## Responsibility boundary

The arrival service does not:

- Change scenes
- Settle score or loot
- Create another journey
- Repair or refuel the craft

Scene routing remains in `FlightFlowController` and expedition settlement
belongs to the Hub layer.
