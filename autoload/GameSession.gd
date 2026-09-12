extends Node
## Owns the state for one loaded campaign. It does not control scenes or game flow.

signal state_models_replaced
signal session_initialized
signal session_cleared
signal current_location_changed(location_id: StringName)
signal expedition_started(expedition: ExpeditionState)
signal expedition_cleared(expedition: ExpeditionState)
signal journey_started(journey: JourneyState)
signal journey_cleared(journey: JourneyState)

var profile: ProfileState = ProfileState.new()
var craft: CraftState = CraftState.new()
var player: PlayerState = PlayerState.new()
var active_expedition: ExpeditionState
var active_journey: JourneyState
var current_location_id: StringName = &""

var _initialized: bool = false


func _ready() -> void:
	initialize_new_game()


func initialize_new_game() -> void:
	profile = ProfileState.new()
	craft = CraftState.new()
	player = PlayerState.new()
	active_expedition = null
	active_journey = null
	current_location_id = &""
	_initialized = true
	state_models_replaced.emit()
	session_initialized.emit()


func clear_session() -> void:
	var previous_expedition := active_expedition
	var previous_journey := active_journey
	profile = ProfileState.new()
	craft = CraftState.new()
	player = PlayerState.new()
	active_expedition = null
	active_journey = null
	current_location_id = &""
	_initialized = false
	state_models_replaced.emit()
	if previous_expedition != null:
		expedition_cleared.emit(previous_expedition)
	if previous_journey != null:
		journey_cleared.emit(previous_journey)
	session_cleared.emit()


func is_initialized() -> bool:
	return _initialized


func set_current_location(location_id: StringName) -> void:
	if current_location_id == location_id:
		return
	current_location_id = location_id
	current_location_changed.emit(current_location_id)


func begin_expedition(expedition: ExpeditionState) -> bool:
	if expedition == null:
		push_error("GameSession: expedition cannot be null")
		return false
	if active_expedition != null:
		push_warning("GameSession: an expedition is already active")
		return false
	active_expedition = expedition
	expedition_started.emit(active_expedition)
	return true


func has_active_expedition() -> bool:
	return active_expedition != null


func require_active_expedition() -> ExpeditionState:
	if active_expedition == null:
		push_error("GameSession: no active expedition")
	return active_expedition


func clear_expedition() -> void:
	if active_expedition == null:
		return
	var completed_expedition := active_expedition
	active_expedition = null
	expedition_cleared.emit(completed_expedition)


func begin_journey(journey: JourneyState) -> bool:
	if journey == null:
		push_error("GameSession: journey cannot be null")
		return false
	if active_journey != null:
		push_warning("GameSession: a journey is already active")
		return false
	if not journey.can_start_with(craft.fuel_tank):
		push_warning("GameSession: journey is invalid or requires more fuel")
		return false
	if not journey.start():
		push_warning("GameSession: journey cannot be started from its current status")
		return false
	active_journey = journey
	journey_started.emit(active_journey)
	return true


func has_active_journey() -> bool:
	return active_journey != null


func require_active_journey() -> JourneyState:
	if active_journey == null:
		push_error("GameSession: no active journey")
	return active_journey


func clear_journey() -> void:
	if active_journey == null:
		return
	var previous_journey := active_journey
	active_journey = null
	journey_cleared.emit(previous_journey)
