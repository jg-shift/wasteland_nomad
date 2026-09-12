extends RefCounted
class_name JourneyState

enum Status {
	PLANNED,
	IN_FLIGHT,
	CRASHED,
	COMPLETED,
}

signal status_changed(status: Status)
signal progress_changed(travelled_distance: float, total_distance: float)
signal fuel_consumed(gallons: float, total_consumed_gallons: float)

var origin_location_id: StringName
var destination_location_id: StringName
var origin_coordinates: Vector2
var destination_coordinates: Vector2
var total_distance: float
var travelled_distance: float = 0.0
var required_fuel_gallons: float
var consumed_fuel_gallons: float = 0.0
var gallons_per_map_unit: float
var flight_seed: int
var status: Status = Status.PLANNED


func _init(
	origin: LocationDefinition = null,
	destination: LocationDefinition = null,
	p_gallons_per_map_unit: float = 0.5,
	p_flight_seed: int = 0
) -> void:
	gallons_per_map_unit = maxf(0.001, p_gallons_per_map_unit)
	flight_seed = p_flight_seed

	if origin == null or destination == null:
		return

	origin_location_id = origin.location_id
	destination_location_id = destination.location_id
	origin_coordinates = origin.map_coordinates
	destination_coordinates = destination.map_coordinates
	total_distance = TravelCostCalculator.calculate_distance(
		origin_coordinates,
		destination_coordinates
	)
	required_fuel_gallons = TravelCostCalculator.calculate_fuel_required(
		total_distance,
		gallons_per_map_unit
	)


func is_valid() -> bool:
	return (
		not origin_location_id.is_empty()
		and not destination_location_id.is_empty()
		and origin_location_id != destination_location_id
		and total_distance > 0.0
	)


func get_progress() -> float:
	if total_distance <= 0.0:
		return 0.0
	return clampf(travelled_distance / total_distance, 0.0, 1.0)


func get_remaining_distance() -> float:
	return maxf(0.0, total_distance - travelled_distance)


func get_remaining_fuel_gallons() -> float:
	return maxf(0.0, required_fuel_gallons - consumed_fuel_gallons)


func can_start_with(fuel_tank: FuelTankState) -> bool:
	return (
		is_valid()
		and fuel_tank != null
		and TravelCostCalculator.can_afford(
			fuel_tank.get_fuel_gallons(),
			get_remaining_distance(),
			gallons_per_map_unit
		)
	)


func start() -> bool:
	if status != Status.PLANNED or not is_valid():
		return false
	_set_status(Status.IN_FLIGHT)
	return true


func crash() -> bool:
	if status != Status.IN_FLIGHT:
		return false
	_set_status(Status.CRASHED)
	return true


func resume() -> bool:
	if status != Status.CRASHED:
		return false
	_set_status(Status.IN_FLIGHT)
	return true


func advance(requested_distance: float, fuel_tank: FuelTankState) -> float:
	if status != Status.IN_FLIGHT or requested_distance <= 0.0 or fuel_tank == null:
		return 0.0

	var affordable_distance := TravelCostCalculator.calculate_maximum_distance(
		fuel_tank.get_fuel_gallons(),
		gallons_per_map_unit
	)
	var actual_distance := minf(
		requested_distance,
		minf(get_remaining_distance(), affordable_distance)
	)
	if actual_distance <= 0.0:
		return 0.0

	var fuel_for_step := TravelCostCalculator.calculate_fuel_required(
		actual_distance,
		gallons_per_map_unit
	)
	if not fuel_tank.consume_fuel(fuel_for_step):
		return 0.0

	travelled_distance = minf(total_distance, travelled_distance + actual_distance)
	consumed_fuel_gallons = minf(
		required_fuel_gallons,
		consumed_fuel_gallons + fuel_for_step
	)
	fuel_consumed.emit(fuel_for_step, consumed_fuel_gallons)
	progress_changed.emit(travelled_distance, total_distance)

	if is_equal_approx(travelled_distance, total_distance):
		_set_status(Status.COMPLETED)

	return actual_distance


func _set_status(value: Status) -> void:
	if status == value:
		return
	status = value
	status_changed.emit(status)
