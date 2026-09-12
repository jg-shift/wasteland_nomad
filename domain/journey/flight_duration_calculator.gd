extends RefCounted
class_name FlightDurationCalculator

const DEFAULT_MAP_UNITS_PER_SECOND: float = 1.0 / 6.0


static func calculate_duration(
	distance: float,
	map_units_per_second: float = DEFAULT_MAP_UNITS_PER_SECOND
) -> float:
	if distance <= 0.0 or map_units_per_second <= 0.0:
		return 0.0
	return distance / map_units_per_second
