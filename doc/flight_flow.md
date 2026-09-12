# Flight Flow

## Purpose

Flight timing and scene navigation are separate responsibilities.

`FlightSettings` owns the duration, normalized progress, and speed curve.
`FlightFlowController` reacts to Flight outcomes and coordinates campaign state
with `SceneRouter`.

```text
FlightSettings
   |       |
   |       +-- flight_crashed
   +---------- flight_completed
                |
                v
      FlightFlowController
                |
                +-- JourneyState
                +-- GameSession
                +-- SceneRouter
```

## FlightSettings

`FlightSettings` continues to:

- Reset normalized Flight progress on entry
- Advance progress from `0.0` to `1.0`
- Apply the Flight speed multiplier curve
- Observe craft destruction
- Stop processing after one terminal outcome

It now emits one of two signals:

```gdscript
signal flight_completed
signal flight_crashed
```

It no longer changes scenes directly.

## Normal completion

With an active journey, normal completion resolves destination arrival and
opens the matching destination shell. Flight without a journey still opens the
configured `finish_scene_path`.

The `FlightJourneyAdapter` has already advanced the journey to its destination
before `flight_completed` is emitted because Godot signals are delivered
synchronously. Arrival behavior is described in
[`journey_arrival.md`](journey_arrival.md).

## Crash with an active journey

When the craft is destroyed:

1. `FlightSettings` stops progress and resets visual Flight speed.
2. `FlightFlowController` changes the active journey to `CRASHED`.
3. The session's current location becomes `tutorial_crash_site`.
4. `SceneRouter.open_walk()` schedules a deferred transition.

The active journey and expedition are not cleared. Travelled distance, fuel,
score, and unsecured loot remain available for repair and resumed Flight.

## Legacy Flight

Flight can still be started without an active journey by legacy scenes.

For that case, both normal completion and craft destruction use the configured
legacy `finish_scene_path`. No journey or fuel state is created implicitly.

## Physics safety

Craft destruction can originate inside a physics collision callback.
`FlightFlowController` uses `SceneRouter`, whose transition is deferred. This
prevents physics objects from being removed during the callback.

## Next integration

The crash-site controller now performs repair and resume as described in
[`crash_repair_resume.md`](crash_repair_resume.md).

The next integration settles expedition score and unsecured loot at a Hub.
