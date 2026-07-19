extends RefCounted
class_name FlightProgressState

signal changed(progress: float)

var _progress: float = 0.0


func get_progress() -> float:
	return _progress


func set_progress(progress: float) -> void:
	var new_progress := clampf(progress, 0.0, 1.0)
	if is_equal_approx(_progress, new_progress):
		return
	_progress = new_progress
	changed.emit(_progress)


func reset() -> void:
	set_progress(0.0)
