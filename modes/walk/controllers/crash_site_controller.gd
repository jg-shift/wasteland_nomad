extends Node
class_name CrashSiteController

@export var crashed_craft: CrashedCraft
@export var map_units_per_second: float = (
	FlightDurationCalculator.DEFAULT_MAP_UNITS_PER_SECOND
)
@export var final_speed_multiplier: float = 3.0
@export var make_repairable_on_ready: bool = true

var _resume_pending: bool = false


func _ready() -> void:
	if crashed_craft == null:
		push_error("CrashSiteController: assign CrashedCraft in the Inspector")
		return

	crashed_craft.repair_completed.connect(_on_repair_completed)
	crashed_craft.resume_requested.connect(_on_resume_requested)

	if make_repairable_on_ready:
		crashed_craft.make_repairable()


func _exit_tree() -> void:
	if crashed_craft == null:
		return
	if crashed_craft.repair_completed.is_connected(_on_repair_completed):
		crashed_craft.repair_completed.disconnect(_on_repair_completed)
	if crashed_craft.resume_requested.is_connected(_on_resume_requested):
		crashed_craft.resume_requested.disconnect(_on_resume_requested)


func _on_repair_completed() -> void:
	GameState.reset_craft_hp()


func _on_resume_requested() -> void:
	if _resume_pending:
		return
	if not GameSession.has_active_journey():
		push_error("CrashSiteController: no journey is available to resume")
		return

	var journey := GameSession.active_journey
	if journey.status != JourneyState.Status.CRASHED:
		push_error("CrashSiteController: active journey is not crashed")
		return
	if GameState.get_craft_hp() <= 0:
		push_error("CrashSiteController: craft must be repaired before resuming")
		return

	var remaining_distance := journey.get_remaining_distance()
	var duration_sec := FlightDurationCalculator.calculate_duration(
		remaining_distance,
		map_units_per_second
	)
	if duration_sec <= 0.0:
		push_error("CrashSiteController: journey has no remaining Flight distance")
		return
	if not journey.resume():
		push_error("CrashSiteController: journey could not resume")
		return

	_resume_pending = true
	Callable(SceneRouter, "start_flight").call_deferred(
		duration_sec,
		final_speed_multiplier
	)
