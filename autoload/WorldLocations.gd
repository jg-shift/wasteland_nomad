extends Node
## Read-only project boundary for static world location definitions.

const FIRST_HUB: LocationDefinition = preload(
	"res://data/locations/first_hub.tres"
)
const PROLOGUE_ORIGIN: LocationDefinition = preload(
	"res://data/locations/prologue_origin.tres"
)
const TUTORIAL_CRASH_SITE: LocationDefinition = preload(
	"res://data/locations/tutorial_crash_site.tres"
)

var _registry: LocationRegistry = LocationRegistry.new()


func _ready() -> void:
	_registry.register_location(FIRST_HUB)
	_registry.register_location(PROLOGUE_ORIGIN)
	_registry.register_location(TUTORIAL_CRASH_SITE)


func has_location(location_id: StringName) -> bool:
	return _registry.has_location(location_id)


func find_location(location_id: StringName) -> LocationDefinition:
	return _registry.find_location(location_id)


func require_location(location_id: StringName) -> LocationDefinition:
	return _registry.require_location(location_id)


func get_all_locations() -> Array[LocationDefinition]:
	return _registry.get_all_locations()


func get_locations_by_type(
	location_type: LocationDefinition.LocationType
) -> Array[LocationDefinition]:
	return _registry.get_locations_by_type(location_type)


func get_available_destinations(
	discovered_location_ids: Array[StringName],
	origin_location_id: StringName = &""
) -> Array[LocationDefinition]:
	return _registry.get_available_destinations(
		discovered_location_ids,
		origin_location_id
	)
