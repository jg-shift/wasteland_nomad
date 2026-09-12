extends Node
class_name FlightJourneyAdapter

signal distance_advanced(distance: float)
signal advance_blocked(requested_distance: float)

var _journey: JourneyState
var _segment_start_distance: float = 0.0
var _segment_distance: float = 0.0


func _ready() -> void:
	if not GameSession.has_active_journey():
		return

	_journey = GameSession.active_journey
	if _journey.status != JourneyState.Status.IN_FLIGHT:
		push_warning("FlightJourneyAdapter: active journey is not in flight")
		_journey = null
		return

	_segment_start_distance = _journey.travelled_distance
	_segment_distance = _journey.get_remaining_distance()
	GameState.flight_progress_changed.connect(_on_flight_progress_changed)


func _exit_tree() -> void:
	if GameState.flight_progress_changed.is_connected(_on_flight_progress_changed):
		GameState.flight_progress_changed.disconnect(_on_flight_progress_changed)


func is_bound() -> bool:
	return _journey != null


func get_segment_start_distance() -> float:
	return _segment_start_distance


func get_segment_distance() -> float:
	return _segment_distance


func _on_flight_progress_changed(progress: float) -> void:
	if _journey == null:
		return
	if GameSession.active_journey != _journey:
		return
	if _journey.status != JourneyState.Status.IN_FLIGHT:
		return

	var normalized_progress := clampf(progress, 0.0, 1.0)
	var target_distance := (
		_segment_start_distance + _segment_distance * normalized_progress
	)
	var requested_distance := target_distance - _journey.travelled_distance
	if requested_distance <= 0.000001:
		return

	var advanced_distance := _journey.advance(
		requested_distance,
		GameSession.craft.fuel_tank
	)
	if advanced_distance > 0.0:
		distance_advanced.emit(advanced_distance)
	if advanced_distance + 0.000001 < requested_distance:
		advance_blocked.emit(requested_distance - advanced_distance)
