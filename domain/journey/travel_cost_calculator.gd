extends RefCounted
class_name TravelCostCalculator


static func calculate_distance(origin: Vector2, destination: Vector2) -> float:
	return origin.distance_to(destination)


static func calculate_fuel_required(
	distance: float,
	gallons_per_map_unit: float
) -> float:
	return maxf(0.0, distance) * maxf(0.0, gallons_per_map_unit)


static func calculate_maximum_distance(
	available_fuel_gallons: float,
	gallons_per_map_unit: float
) -> float:
	if gallons_per_map_unit <= 0.0:
		return 0.0
	return maxf(0.0, available_fuel_gallons) / gallons_per_map_unit


static func can_afford(
	available_fuel_gallons: float,
	distance: float,
	gallons_per_map_unit: float
) -> bool:
	var required := calculate_fuel_required(distance, gallons_per_map_unit)
	return maxf(0.0, available_fuel_gallons) + 0.000001 >= required
