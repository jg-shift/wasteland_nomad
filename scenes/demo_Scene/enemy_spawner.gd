extends Node2D
class_name EnemySpawner

signal enemy_died(victory_points: int)
signal collision_damage_requested(amount: int)

## Drag the enemy .tscn file here in the Inspector
@export var enemy_scene: PackedScene
@export var player: Node2D

## Spawn interval at minimum flight_speed
@export var spawn_interval_sec: float = 1.5
## Lower clamp for very high spawn multipliers
@export var spawn_interval_min_sec: float = 0.2

@export var spawn_x_padding: float = 24.0
@export var spawn_y_offset: float = 120.0

var _timer: Timer


func _ready() -> void:
	if enemy_scene == null:
		push_error("EnemySpawner: assign enemy_scene in Inspector")
		set_process(false)
		return
	if player == null:
		push_error("EnemySpawner: assign player in Inspector")
		set_process(false)
		return

	_timer = Timer.new()
	_timer.one_shot = false
	_timer.wait_time = _current_interval()
	add_child(_timer)
	_timer.timeout.connect(_spawn_one)
	_timer.start()


func _process(_delta: float) -> void:
	_timer.wait_time = _current_interval()


func _current_interval() -> float:
	var base_interval := lerpf(spawn_interval_sec, spawn_interval_min_sec, WorldUtils.BASE_FLIGHT_SPEED)
	var spawn_multiplier := maxf(0.001, WorldUtils.flight_speed_multiplier)
	return maxf(spawn_interval_min_sec, base_interval / spawn_multiplier)


func _spawn_one() -> void:
	var rect := WorldUtils.world_view_rect(get_viewport())

	var x := randf_range(rect.position.x + spawn_x_padding, rect.position.x + rect.size.x - spawn_x_padding)
	var y  := rect.position.y - spawn_y_offset

	var size_t := randf()

	var e := enemy_scene.instantiate() as BaseEnemy
	if e == null:
		push_error("EnemySpawner: enemy_scene root is not a BaseEnemy node")
		return

	get_parent().add_child(e)
	e.global_position = Vector2(x, y)
	e.died.connect(_on_enemy_died)
	e.collision_damage_requested.connect(_on_collision_damage_requested)
	e.setup(player, size_t)


func _on_enemy_died(victory_points: int) -> void:
	enemy_died.emit(victory_points)


func _on_collision_damage_requested(amount: int) -> void:
	collision_damage_requested.emit(amount)
