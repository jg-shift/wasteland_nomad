extends RefCounted
class_name FuelTankState

signal fuel_changed(fuel_gallons: float, capacity_gallons: float)
signal capacity_changed(capacity_gallons: float)
signal consumption_changed(gallons_per_map_unit: float)

var _fuel_gallons: float
var _capacity_gallons: float
var _gallons_per_map_unit: float


func _init(
	initial_capacity_gallons: float = 20.0,
	initial_fuel_gallons: float = 20.0,
	initial_gallons_per_map_unit: float = 0.5
) -> void:
	_capacity_gallons = maxf(0.01, initial_capacity_gallons)
	_fuel_gallons = clampf(initial_fuel_gallons, 0.0, _capacity_gallons)
	_gallons_per_map_unit = maxf(0.001, initial_gallons_per_map_unit)


func get_fuel_gallons() -> float:
	return _fuel_gallons


func get_capacity_gallons() -> float:
	return _capacity_gallons


func get_gallons_per_map_unit() -> float:
	return _gallons_per_map_unit


func set_fuel_gallons(value: float) -> void:
	var new_fuel := clampf(value, 0.0, _capacity_gallons)
	if is_equal_approx(_fuel_gallons, new_fuel):
		return
	_fuel_gallons = new_fuel
	fuel_changed.emit(_fuel_gallons, _capacity_gallons)


func add_fuel(gallons: float) -> void:
	if gallons <= 0.0:
		return
	set_fuel_gallons(_fuel_gallons + gallons)


func consume_fuel(gallons: float) -> bool:
	if gallons < 0.0:
		push_error("FuelTankState: fuel consumption cannot be negative")
		return false
	if gallons <= 0.0:
		return true
	if _fuel_gallons + 0.000001 < gallons:
		return false
	set_fuel_gallons(_fuel_gallons - gallons)
	return true


func set_capacity_gallons(value: float) -> void:
	var new_capacity := maxf(0.01, value)
	if is_equal_approx(_capacity_gallons, new_capacity):
		return
	_capacity_gallons = new_capacity
	_fuel_gallons = minf(_fuel_gallons, _capacity_gallons)
	capacity_changed.emit(_capacity_gallons)
	fuel_changed.emit(_fuel_gallons, _capacity_gallons)


func set_gallons_per_map_unit(value: float) -> void:
	var new_consumption := maxf(0.001, value)
	if is_equal_approx(_gallons_per_map_unit, new_consumption):
		return
	_gallons_per_map_unit = new_consumption
	consumption_changed.emit(_gallons_per_map_unit)


func fill() -> void:
	set_fuel_gallons(_capacity_gallons)
