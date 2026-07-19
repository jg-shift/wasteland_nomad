extends RefCounted
class_name ScoreState

signal changed(points: int)

var _points: int = 0


func get_points() -> int:
	return _points


func set_points(value: int) -> void:
	var new_points := maxi(0, value)
	if _points == new_points:
		return
	_points = new_points
	changed.emit(_points)


func add_points(amount: int) -> void:
	if amount <= 0:
		return
	set_points(_points + amount)


func reset() -> void:
	set_points(0)
