extends Node2D
class_name EnemySpawner

@export var enemy_template: Enemy
@export var player: Node2D

@export var spawn_interval_sec: float = 0.5
@export var spawn_x_padding: float = 24.0
@export var spawn_y_offset: float = 120.0

# вариативность ±20%
@export var min_var: float = 0.5
@export var max_var: float = 1.0

# “около 1” = прямой полёт
@export var straight_deadzone: float = 0.75

var _timer: Timer


func _ready() -> void:
	if enemy_template == null:
		push_error("EnemySpawner: assign enemy_template in Inspector")
		set_process(false)
		return
	if player == null:
		push_error("EnemySpawner: assign player in Inspector")
		set_process(false)
		return

	# шаблон отключаем
	enemy_template.freeze = true
	enemy_template.visible = false
	enemy_template.set_physics_process(false)
	enemy_template.set_process(false)
	enemy_template.gravity_scale = 0.0
	var cs := enemy_template.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs: cs.disabled = true

	_timer = Timer.new()
	_timer.one_shot = false
	_timer.wait_time = spawn_interval_sec
	add_child(_timer)
	_timer.timeout.connect(_spawn_one)
	_timer.start()


func _spawn_one() -> void:
	var rect := _world_view_rect()

	# позиция спавна: чуть выше экрана
	var x := randf_range(rect.position.x + spawn_x_padding, rect.position.x + rect.size.x - spawn_x_padding)
	var y := rect.position.y - spawn_y_offset

	# вариативность
	var scale_var := randf_range(min_var, max_var)
	var sat_var := randf_range(min_var, max_var)
	var behavior := randf_range(min_var, max_var)

	# если очень близко к 1 — делаем ровно 1 (строго прямо)
	if absf(behavior - 1.0) <= straight_deadzone:
		behavior = 1.0

	# создаём копию
	var e := enemy_template.duplicate() as Enemy
	get_parent().add_child(e)

	e.global_position = Vector2(x, y)

	# включаем всё
	e.visible = true
	e.freeze = false
	e.set_physics_process(true)
	e.set_process(true)
	e.gravity_scale = 0.0

	var cs := e.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs: cs.disabled = false

	# передаём параметры
	e.setup(player, behavior, scale_var, sat_var)


func _world_view_rect() -> Rect2:
	var vp_rect := get_viewport().get_visible_rect()
	var canvas_xform := get_viewport().get_canvas_transform()
	var tl := canvas_xform.affine_inverse() * vp_rect.position
	var br := canvas_xform.affine_inverse() * (vp_rect.position + vp_rect.size)
	return Rect2(tl, br - tl)
