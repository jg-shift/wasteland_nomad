extends Node
## Centralizes scene construction and transitions.

const FLIGHT_SCENE: PackedScene = preload("res://modes/flight/flight.tscn")

var _transition_pending: bool = false


func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)


func start_flight(
	duration_sec: float = 120.0,
	final_speed_multiplier: float = 3.0,
	finish_scene_path: String = ""
) -> void:
	var flight_scene := FLIGHT_SCENE.instantiate()
	var settings := flight_scene.get_node_or_null("FlightSettings") as FlightSettings
	if settings == null:
		push_error("SceneRouter: flight scene requires a FlightSettings node")
		flight_scene.queue_free()
		return

	settings.configure(duration_sec, final_speed_multiplier, finish_scene_path)
	_replace_current_scene(flight_scene)


func change_scene_to_file(scene_path: String) -> void:
	if scene_path.is_empty():
		push_error("SceneRouter: scene path cannot be empty")
		return
	if _transition_pending:
		return

	_transition_pending = true
	Callable(self, "_perform_change_scene_to_file").call_deferred(scene_path)


func _perform_change_scene_to_file(scene_path: String) -> void:
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		_transition_pending = false
		push_error("SceneRouter: failed to change scene to '%s' (error %d)" % [scene_path, error])


func _on_scene_changed() -> void:
	_transition_pending = false


func _replace_current_scene(new_scene: Node) -> void:
	var old_scene := get_tree().current_scene
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	if old_scene != null:
		old_scene.queue_free()
