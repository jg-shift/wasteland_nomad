extends Node
class_name FlightSettings

signal flight_completed
signal flight_crashed

@export var duration_sec: float = 120.0
@export var final_speed_multiplier: float = 3.0
@export var acceleration_start_ratio: float = 0.5
@export var acceleration_duration_sec: float = 30.0
@export_file("*.tscn") var finish_scene_path: String = "res://scenes/shop_beta.tscn"

var _elapsed_sec: float = 0.0
var _finished: bool = false


func configure(
	p_duration_sec: float = 120.0,
	p_final_speed_multiplier: float = 3.0,
	p_finish_scene_path: String = ""
) -> void:
	duration_sec = maxf(0.1, p_duration_sec)
	final_speed_multiplier = maxf(1.0, p_final_speed_multiplier)
	if p_finish_scene_path != "":
		finish_scene_path = p_finish_scene_path


func _ready() -> void:
	_elapsed_sec = 0.0
	_finished = false
	GameState.enter_flight()
	GameState.reset_flight_progress()
	WorldUtils.set_flight_speed_multiplier(1.0)

	if not GameState.craft_destroyed.is_connected(_on_craft_destroyed):
		GameState.craft_destroyed.connect(_on_craft_destroyed)


func _exit_tree() -> void:
	if GameState.craft_destroyed.is_connected(_on_craft_destroyed):
		GameState.craft_destroyed.disconnect(_on_craft_destroyed)


func _process(delta: float) -> void:
	if _finished:
		return

	_elapsed_sec += delta
	GameState.set_flight_progress(_elapsed_sec / duration_sec)
	_update_flight_speed()

	if _elapsed_sec >= duration_sec:
		_complete_flight()


func _update_flight_speed() -> void:
	var acceleration_start_sec := duration_sec * clampf(acceleration_start_ratio, 0.0, 1.0)
	var final_speed_time_sec := minf(duration_sec, acceleration_start_sec + acceleration_duration_sec)

	if _elapsed_sec <= acceleration_start_sec:
		WorldUtils.set_flight_speed_multiplier(1.0)
		return

	if _elapsed_sec >= final_speed_time_sec:
		WorldUtils.set_flight_speed_multiplier(final_speed_multiplier)
		return

	var t := (_elapsed_sec - acceleration_start_sec) / (final_speed_time_sec - acceleration_start_sec)
	WorldUtils.set_flight_speed_multiplier(lerpf(1.0, final_speed_multiplier, t))


func _complete_flight() -> void:
	_finished = true
	WorldUtils.set_flight_speed_multiplier(1.0)
	flight_completed.emit()


func _on_craft_destroyed() -> void:
	if _finished:
		return
	_finished = true
	WorldUtils.set_flight_speed_multiplier(1.0)
	flight_crashed.emit()
