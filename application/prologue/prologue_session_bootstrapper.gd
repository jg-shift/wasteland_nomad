extends RefCounted
class_name PrologueSessionBootstrapper

const EXPEDITION_ID: StringName = &"prologue"
const ORIGIN_LOCATION_ID: StringName = &"prologue_origin"
const DESTINATION_LOCATION_ID: StringName = &"first_hub"
const FLIGHT_SEED: int = 20260721


static func start_new_game() -> bool:
	GameSession.initialize_new_game()
	GameState.reset_points()
	GameState.reset_flight_progress()
	GameSession.set_current_location(ORIGIN_LOCATION_ID)

	var expedition := ExpeditionState.new(EXPEDITION_ID)
	if not GameSession.begin_expedition(expedition):
		push_error("PrologueSessionBootstrapper: could not start prologue expedition")
		return false

	var origin := WorldLocations.require_location(ORIGIN_LOCATION_ID)
	var destination := WorldLocations.require_location(DESTINATION_LOCATION_ID)
	if origin == null or destination == null:
		GameSession.clear_expedition()
		push_error("PrologueSessionBootstrapper: prologue locations are unavailable")
		return false

	var journey := JourneyState.new(
		origin,
		destination,
		GameSession.craft.fuel_tank.get_gallons_per_map_unit(),
		FLIGHT_SEED
	)
	if not GameSession.begin_journey(journey):
		GameSession.clear_expedition()
		push_error("PrologueSessionBootstrapper: could not start prologue journey")
		return false

	return true
