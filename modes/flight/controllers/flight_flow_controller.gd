extends Node
class_name FlightFlowController

const TUTORIAL_CRASH_SITE_ID: StringName = &"tutorial_crash_site"

@export var flight_settings: FlightSettings


func _ready() -> void:
	if flight_settings == null:
		push_error("FlightFlowController: assign FlightSettings in the Inspector")
		return

	flight_settings.flight_completed.connect(_on_flight_completed)
	flight_settings.flight_crashed.connect(_on_flight_crashed)


func _on_flight_completed() -> void:
	if not GameSession.has_active_journey():
		SceneRouter.change_scene_to_file(flight_settings.finish_scene_path)
		return

	var planned_destination := WorldLocations.find_location(
		GameSession.active_journey.destination_location_id
	)
	if (
		planned_destination == null
		or (
			planned_destination.location_type
			!= LocationDefinition.LocationType.HUB
		)
	):
		push_error(
			"FlightFlowController: destination type is not supported yet"
		)
		return

	var destination := JourneyArrivalService.complete_active_journey()
	if destination == null:
		return

	SceneRouter.open_hub()


func _on_flight_crashed() -> void:
	if not GameSession.has_active_journey():
		# Preserve legacy Flight behavior when it was started without a journey.
		SceneRouter.change_scene_to_file(flight_settings.finish_scene_path)
		return

	var journey := GameSession.active_journey
	if journey.status == JourneyState.Status.IN_FLIGHT:
		journey.crash()
	elif journey.status != JourneyState.Status.CRASHED:
		push_error("FlightFlowController: journey cannot enter the crashed state")
		return

	GameSession.set_current_location(TUTORIAL_CRASH_SITE_ID)
	SceneRouter.open_walk()
