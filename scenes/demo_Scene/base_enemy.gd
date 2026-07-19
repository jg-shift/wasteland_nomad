extends DamageableBody2D
class_name BaseEnemy

signal died(victory_points: int)
signal collision_damage_requested(amount: int)

@export var min_victory_points: int = 10
@export var max_victory_points: int = 100

var victory_points: int


func setup(_p_player: Node2D, size_t: float) -> void:
	setup_victory_points(size_t)


func setup_victory_points(size_t: float) -> void:
	var clamped_size_t := clampf(size_t, 0.0, 1.0)
	victory_points = roundi(lerpf(float(min_victory_points), float(max_victory_points), clamped_size_t))


func emit_died() -> void:
	died.emit(victory_points)


func request_collision_damage(amount: int) -> void:
	collision_damage_requested.emit(amount)
