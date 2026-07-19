extends RefCounted
class_name GameModeState

signal changed(mode: int)

var _mode: int


func _init(initial_mode: int) -> void:
	_mode = initial_mode


func get_mode() -> int:
	return _mode


func set_mode(mode: int) -> void:
	if _mode == mode:
		return
	_mode = mode
	changed.emit(_mode)
