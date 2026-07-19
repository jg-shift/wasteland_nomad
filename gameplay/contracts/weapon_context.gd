extends RefCounted
class_name WeaponContext

var source: Node2D
var team: int


func _init(p_source: Node2D, p_team: int) -> void:
	source = p_source
	team = p_team
