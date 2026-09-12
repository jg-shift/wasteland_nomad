# Prologue Session Bootstrap

## Purpose

The opening Flight is the only journey that begins without destination
selection on the interactive map. `PrologueSessionBootstrapper` creates the
same domain state that the map will create for later journeys.

This prevents the tutorial from becoming a separate legacy game mode.

## Opening world coordinates

```text
Prologue Origin        Tutorial Crash Site        First Hub
    (-20, 0)                 (-10, 0)                (0, 0)
        |-----------------------|-----------------------|
```

The prologue journey runs from `prologue_origin` to `first_hub`. The tutorial
crash site is positioned halfway along that route.

All three coordinates are abstract map units. They can be rebalanced in their
location resources without changing IDs or gameplay code.

`prologue_origin` and `tutorial_crash_site` are not selectable destinations.

## New-game sequence

`PrologueSessionBootstrapper.start_new_game()`:

1. Replaces the current campaign with a fresh `GameSession`.
2. Resets compatibility score and Flight progress.
3. Sets the current location to `prologue_origin`.
4. Starts the `prologue` expedition.
5. Creates a journey from `prologue_origin` to `first_hub`.
6. Starts the journey with a deterministic Flight seed.

Only after this succeeds does the main menu call `SceneRouter.start_flight()`.

```text
Start button
     |
     v
PrologueSessionBootstrapper
     |
     +-- fresh GameSession
     +-- prologue ExpeditionState
     +-- active JourneyState
     |
     v
Existing Flight scene
```

## Initial journey values

With the provisional fuel configuration:

```text
Distance:       20 map units
Consumption:   0.5 gallons per map unit
Required fuel: 10 gallons
Starting fuel: 20 gallons
```

The bootstrapper does not consume fuel. Fuel consumption begins when the
Flight journey adapter advances the active journey.

## Failure behavior

If the expedition or journey cannot start, the main menu remains open. A
partially created expedition is cleared when location lookup or journey
creation fails.

The bootstrapper does not change scenes. Scene transitions remain the
responsibility of `SceneRouter`.
