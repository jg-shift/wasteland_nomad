# Flight Journey Adapter

## Purpose

`FlightJourneyAdapter` connects the existing time-based Flight implementation
to the coordinate- and fuel-based journey domain without changing Flight's
public state API.

Existing Flight code continues to publish normalized progress:

```text
GameState.flight_progress: 0.0 -> 1.0
```

The adapter translates that progress into travelled map distance:

```text
Normalized Flight progress
            |
            v
FlightJourneyAdapter
            |
            +-- JourneyState.advance(distance)
            +-- FuelTankState.consume_fuel(gallons)
```

## Flight segment snapshot

When a Flight scene begins, the adapter records:

- The journey's current travelled distance
- The journey's remaining distance

These form one Flight segment:

```gdscript
_segment_start_distance = journey.travelled_distance
_segment_distance = journey.get_remaining_distance()
```

For each normalized progress update, it calculates the absolute target:

```gdscript
target_distance = (
	segment_start_distance
	+ segment_distance * normalized_progress
)
```

Only the difference between the target and current journey distance is
advanced. This prevents duplicate fuel consumption if the same progress value
is emitted more than once.

## Crash and resume

When a later Flight segment begins after repair, the adapter snapshots the
journey again:

```text
Original journey:       20 units
Travelled before crash:  8 units
New segment distance:   12 units
```

The resumed Flight can use a fresh normalized range from `0.0` to `1.0` while
the journey keeps its absolute 8-unit starting position.

## Legacy compatibility

When no active journey exists, the adapter does not connect to Flight progress
and performs no work.

This preserves Flight started by legacy scenes such as the existing workshop:

```text
Legacy Flight
    |
    +-- existing progress, timing, enemies, score, and transition
    +-- no journey distance changes
    +-- no fuel consumption
```

No existing callers need to replace:

```gdscript
GameState.set_flight_progress(progress)
GameState.get_flight_progress()
GameState.flight_progress_changed
```

## Fuel behavior

The adapter does not calculate fuel itself. It asks `JourneyState.advance()` to
advance distance using the session craft's `FuelTankState`.

If less distance is advanced than requested, the adapter emits
`advance_blocked`. This gives a future Flight flow controller a failure signal
without placing scene transitions inside the adapter.

## Responsibility boundary

The adapter may:

- Observe normalized Flight progress
- Convert segment progress to a distance delta
- Ask the active journey to advance
- Report blocked advancement

The adapter must not:

- Start or clear journeys
- Mark a journey as crashed
- Change scenes
- Decide arrival behavior
- Repair or refuel the craft

Those decisions belong to the Flight and crash-site flow controllers.
