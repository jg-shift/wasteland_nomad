extends RigidBody2D
class_name Enemy

@export var max_hp: int = 5
@export var base_speed: float = 160.0
@export var steer_strength: float = 140.0 # насколько “тянет” к/от игрока
@export var kill_margin_px: float = 100.0

@export var flash_time: float = 0.3

@onready var sprite: Sprite2D = $Sprite2D
@onready var col: CollisionShape2D = $CollisionShape2D
@onready var explosion: GPUParticles2D = $Explosion


var _mat: ShaderMaterial

var hp: int
var player: Node2D

# вариативность
var var_scale: float = 1.0
var var_saturation: float = 1.0
var var_behavior: float = 0.75 # около 1 -> прямо; >1 -> к игроку; <1 -> от игрока

var _alive: bool = true
var _flash_tween: Tween


func _ready() -> void:
	gravity_scale = 0.0
	lock_rotation = true

	# уникальный материал на инстанс
	if sprite.material != null:
		sprite.material = sprite.material.duplicate()

	var m := sprite.material
	if m is ShaderMaterial:
		_mat = m as ShaderMaterial
		_mat.set_shader_parameter("flash", 0.0)
		_mat.set_shader_parameter("sat_mul", 1.0)
		_mat.set_shader_parameter("val_mul", 1.0)

	hp = max_hp



func setup(p_player: Node2D, p_behavior: float, p_scale: float, p_saturation: float) -> void:
	player = p_player
	var_behavior = p_behavior
	var_scale = p_scale
	var_saturation = p_saturation
	_apply_visual_variation() # ВАЖНО: применяем сразу после установки параметров


func _physics_process(_delta: float) -> void:
	if not _alive:
		return

	# базовое движение вниз
	var v := Vector2(0.0, base_speed)

	# поведение: около 1 -> прямо
	var diff := var_behavior - 0.75
	if absf(diff) > 0.05 and is_instance_valid(player):
		var to_player := (player.global_position - global_position)
		# steer_dir: >0 к игроку, <0 от игрока
		var steer_dir := to_player.normalized() * signf(diff) * 1.5
		# немного “подруливаем” по X (и можно по Y, но обычно X достаточно)
		v += Vector2(steer_dir.x, 0.0) * steer_strength * absf(diff)

	linear_velocity = v

	# автоудаление если улетел ниже экрана на 100px
	var rect := _world_view_rect()
	if global_position.y > rect.position.y + rect.size.y + kill_margin_px:
		queue_free()


func receive_damage(amount: int) -> void:
	if not _alive:
		return
	hp -= amount
	_flash_white()

	if hp <= 0:
		_die()


func _flash_white() -> void:
	# Если шейдер не назначен — просто выходим (или сделай fallback)
	if _mat == null:
		return

	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()

	_mat.set_shader_parameter("flash", 1.0)
	_flash_tween = create_tween()
	_flash_tween.tween_method(
		func(v: float) -> void:
			_mat.set_shader_parameter("flash", v),
		1.0, 0.0, 0.3
	)



func _die() -> void:
	_alive = false
	collision_layer = 0
	collision_mask = 0
	$CollisionShape2D.disabled = true

	# выключаем видимость и коллизию
	if sprite: sprite.visible = false
	if col: col.disabled = true

	# взрыв (one_shot)
	if explosion:
		explosion.global_position = global_position
		explosion.visible = true
		explosion.emitting = true

		# дождаться окончания частиц и удалить
		# Важно: one_shot должен быть true
		var lifetime := explosion.lifetime
		await get_tree().create_timer(lifetime).timeout

	queue_free()


func _apply_visual_variation() -> void:
	# Масштабируем ВИЗУАЛ и ХИТБОКС явно
	if sprite:
		sprite.scale = Vector2(var_scale, var_scale)
	if col:
		col.scale = Vector2(var_scale, var_scale)

	# Насыщенность — если ты уже сделал шейдер (sat_mul)
	if _mat != null:
		_mat.set_shader_parameter("sat_mul", var_saturation)




func _world_view_rect() -> Rect2:
	# корректно и для камеры, и без: через canvas_transform
	var vp_rect := get_viewport().get_visible_rect()
	var canvas_xform := get_viewport().get_canvas_transform()
	var tl := canvas_xform.affine_inverse() * vp_rect.position
	var br := canvas_xform.affine_inverse() * (vp_rect.position + vp_rect.size)
	return Rect2(tl, br - tl)
