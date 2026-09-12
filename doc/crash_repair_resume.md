# Crash Repair and Journey Resume

## Purpose

The crash site interrupts a journey without replacing it. Repair restores the
persistent craft, and resume creates a new Flight segment for only the
remaining journey distance.

```text
Journey IN_FLIGHT
        |
        v
     CRASHED
        |
        +-- repair craft health
        |
        v
    IN_FLIGHT
        |
        v
New Flight segment for remaining distance
```

## CrashSiteController

The tutorial crash-site scene contains `CrashSiteController`, connected to its
`CrashedCraft`.

On scene entry, the controller makes the craft repairable. It observes:

```gdscript
crashed_craft.repair_completed
crashed_craft.resume_requested
```

### Repair completion

Repair completion calls the existing compatibility API:

```gdscript
GameState.reset_craft_hp()
```

The actual health belongs to `GameSession.craft.health`, so it remains repaired
after the Walk scene is removed.

### Resume request

A resume request is accepted only when:

- An active journey exists
- Its status is `CRASHED`
- Persistent craft health is above zero
- Remaining journey distance is greater than zero

The controller changes the same journey back to `IN_FLIGHT`. It never creates a
replacement journey.

## Flight duration

`FlightDurationCalculator` converts remaining abstract map distance into
seconds:

```text
duration = remaining distance / map units per second
```

The provisional rate is:

```text
1 map unit = 6 seconds
```

For the tutorial route:

```text
Full journey:          20 units = 120 seconds
Crash after 5 units:   15 units remain
Resumed Flight:        15 units = 90 seconds
```

This rate is a balancing parameter and does not affect world coordinates or
fuel calculations.

## Transition safety

Return to Flight is deferred. This prevents the Walk scene from being removed
inside an interaction or physics callback.

## Responsibility boundary

`CrashSiteController` coordinates repair and resume. It does not:

- Calculate journey fuel
- Reset journey progress
- Set the destination
- Settle the expedition
- Handle final arrival

Repair-part collection and interaction UI can call the existing methods and
signals on `CrashedCraft` without owning campaign state.
