extends Resource
class_name LocationDefinition

enum LocationType {
	HUB,
	DUNGEON,
	CRASH_SITE,
	SPECIAL,
}

@export var location_id: StringName = &""
@export var display_name: String = ""
@export var map_coordinates: Vector2 = Vector2.ZERO
@export var location_type: LocationType = LocationType.HUB
@export var is_travel_destination: bool = true
@export var content_scene: PackedScene


func _init(
	p_location_id: StringName = &"",
	p_display_name: String = "",
	p_map_coordinates: Vector2 = Vector2.ZERO,
	p_location_type: LocationType = LocationType.HUB,
	p_is_travel_destination: bool = true,
	p_content_scene: PackedScene = null
) -> void:
	location_id = p_location_id
	display_name = p_display_name
	map_coordinates = p_map_coordinates
	location_type = p_location_type
	is_travel_destination = p_is_travel_destination
	content_scene = p_content_scene


func is_valid() -> bool:
	return not location_id.is_empty()
