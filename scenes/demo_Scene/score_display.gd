extends Label


func _ready() -> void:
	_on_points_changed(GameState.get_points())

	if not GameState.points_changed.is_connected(_on_points_changed):
		GameState.points_changed.connect(_on_points_changed)


func _on_points_changed(points: int) -> void:
	text = str(points)
