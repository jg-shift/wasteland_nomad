extends RefCounted
class_name LocationRegistry

signal location_registered(definition: LocationDefinition)

var _locations_by_id: Dictionary = {}
var _registration_order: Array[StringName] = []


func register_location(definition: LocationDefinition) -> bool:
	if definition == null or not definition.is_valid():
		push_error("LocationRegistry: location definition is invalid")
		return false
	if _locations_by_id.has(definition.location_id):
		push_error(
			"LocationRegistry: duplicate location ID '%s'" % definition.location_id
		)
		return false

	_locations_by_id[definition.location_id] = definition
	_registration_order.append(definition.location_id)
	location_registered.emit(definition)
	return true


func has_location(location_id: StringName) -> bool:
	return _locations_by_id.has(location_id)


func find_location(location_id: StringName) -> LocationDefinition:
	return _locations_by_id.get(location_id) as LocationDefinition


func require_location(location_id: StringName) -> LocationDefinition:
	var definition := find_location(location_id)
	if definition == null:
		push_error("LocationRegistry: unknown location ID '%s'" % location_id)
	return definition


func get_all_locations() -> Array[LocationDefinition]:
	var result: Array[LocationDefinition] = []
	for location_id in _registration_order:
		result.append(_locations_by_id[location_id] as LocationDefinition)
	return result


func get_locations_by_type(
	location_type: LocationDefinition.LocationType
) -> Array[LocationDefinition]:
	var result: Array[LocationDefinition] = []
	for definition in get_all_locations():
		if definition.location_type == location_type:
			result.append(definition)
	return result


func get_available_destinations(
	discovered_location_ids: Array[StringName],
	origin_location_id: StringName = &""
) -> Array[LocationDefinition]:
	var result: Array[LocationDefinition] = []
	for location_id in _registration_order:
		if location_id == origin_location_id:
			continue
		if not discovered_location_ids.has(location_id):
			continue
		var definition := _locations_by_id[location_id] as LocationDefinition
		if definition.is_travel_destination:
			result.append(definition)
	return result
