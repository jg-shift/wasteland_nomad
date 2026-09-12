extends RefCounted
class_name JourneyArrivalService

const PROLOGUE_EXPEDITION_ID: StringName = &"prologue"
const FIRST_HUB_ID: StringName = &"first_hub"


static func complete_active_journey() -> LocationDefinition:
	if not GameSession.has_active_journey():
		push_error("JourneyArrivalService: no active journey")
		return null

	var journey := GameSession.active_journey
	if journey.status != JourneyState.Status.COMPLETED:
		push_error("JourneyArrivalService: active journey is not completed")
		return null

	var destination := WorldLocations.find_location(
		journey.destination_location_id
	)
	if destination == null:
		push_error(
			"JourneyArrivalService: destination '%s' is not registered"
			% journey.destination_location_id
		)
		return null

	GameSession.set_current_location(destination.location_id)
	GameSession.profile.discover_location(destination.location_id)

	if (
		destination.location_id == FIRST_HUB_ID
		and GameSession.has_active_expedition()
		and (
			GameSession.active_expedition.expedition_id
			== PROLOGUE_EXPEDITION_ID
		)
	):
		GameSession.profile.complete_prologue()

	GameSession.clear_journey()
	return destination
