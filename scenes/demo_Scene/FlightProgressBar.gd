extends ProgressBar


func _ready() -> void:
	max_value = 100.0
	min_value = 0.0
	value = 0.0

	_on_flight_progress_changed(GameState.get_flight_progress())

	if not GameState.flight_progress_changed.is_connected(_on_flight_progress_changed):
		GameState.flight_progress_changed.connect(_on_flight_progress_changed)


func _on_flight_progress_changed(progress: float) -> void:
	value = progress * 100.0
