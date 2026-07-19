extends BaseEnemy
class_name BetaEnemy

# --- Tuning ranges (all derived from size_t passed in setup()) ---
@export var min_scale: float = 0.5
@export var max_scale: float = 1.5

@export var min_hp: int = 1
@export var max_hp: int = 8

@export var min_saturation: float = 0.2
@export var max_saturation: float = 1.4

## Colour of the explosion for the biggest/most saturated enemy
@export var explosion_color_big: Color = Color(1.0, 0.55, 0.1)
## Colour of the explosion for the smallest/least saturated enemy
@export var explosion_color_small: Color = Color(0.6, 0.6, 0.6)

@export var base_speed: float = 160.0
## At maximum flight_speed enemies move this many times faster downward
@export var speed_scale_at_max: float = 2.5
@export var steer_strength: float = 140.0
@export var kill_margin_px: float = 100.0
@export var flash_time: float = 0.3

@onready var sprite: Sprite2D = $Sprite2D
@onready var col: CollisionShape2D = $CollisionShape2D
@onready var explosion: GPUParticles2D = $Explosion

var _mat: ShaderMaterial

var hp: int
var player: Node2D

# Derived in setup(): -1.0 = flee, 0.0 = straight, +1.0 = chase
var var_scale: float = 1.0
var var_saturation: float = 1.0
var var_behavior: float = 0.0
var _size_t: float = 0.5  # stored for explosion tint

var _alive: bool = true
var _flash_tween: Tween


func _ready() -> void:
	gravity_scale = 0.0
	lock_rotation = true
	contact_monitor = true
	max_contacts_reported = maxi(max_contacts_reported, 1)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if sprite.material != null:
		sprite.material = sprite.material.duplicate()

	var m := sprite.material
	if m is ShaderMaterial:
		_mat = m as ShaderMaterial
		_mat.set_shader_parameter("flash", 0.0)
		_mat.set_shader_parameter("sat_mul", 1.0)
		_mat.set_shader_parameter("val_mul", 1.0)

	hp = max_hp


## size_t: 0.0 = tiny/weak/flees, 1.0 = big/tough/chases
func setup(p_player: Node2D, size_t: float) -> void:
	super.setup(p_player, size_t)
	player         = p_player
	_size_t        = size_t
	var_scale      = lerpf(min_scale, max_scale, size_t)
	hp             = roundi(lerpf(float(min_hp), float(max_hp), size_t))
	var_saturation = lerpf(min_saturation, max_saturation, size_t)
	var_behavior   = lerpf(-1.0, 1.0, size_t)  # negative = flee, positive = chase
	_apply_visual_variation()


func _physics_process(_delta: float) -> void:
	if not _alive:
		return

	# Enemies fly faster as flight_speed increases
	var current_speed := base_speed * lerpf(1.0, speed_scale_at_max, WorldUtils.flight_speed)
	var v := Vector2(0.0, current_speed)

	# Steer toward or away from player based on var_behavior
	if absf(var_behavior) > 0.05 and is_instance_valid(player):
		var to_player := (player.global_position - global_position)
		v += Vector2(to_player.normalized().x, 0.0) * steer_strength * var_behavior

	linear_velocity = v

	var rect := WorldUtils.world_view_rect(get_viewport())
	if global_position.y > rect.position.y + rect.size.y + kill_margin_px:
		queue_free()


func receive_damage(amount: int) -> void:
	if not _alive:
		return
	hp -= amount
	_flash_white()
	if hp <= 0:
		_die()


func _on_body_entered(body: Node) -> void:
	if not _alive:
		return
	if body != player and not body.is_in_group("player"):
		return

	var collision_damage := floori(float(maxi(0, hp))) * 3
	request_collision_damage(collision_damage)
	_die(false)


func _flash_white() -> void:
	if _mat == null:
		return
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_mat.set_shader_parameter("flash", 1.0)
	_flash_tween = create_tween()
	_flash_tween.tween_method(
		func(v: float) -> void:
			_mat.set_shader_parameter("flash", v),
		1.0, 0.0, flash_time
	)


func _die(award_points: bool = true) -> void:
	_alive = false
	if award_points:
		emit_died()
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	if col: col.set_deferred("disabled", true)

	if sprite: sprite.visible = false

	if explosion:
		explosion.global_position = global_position
		explosion.visible = true
		explosion.emitting = true
		var lifetime := explosion.lifetime
		await get_tree().create_timer(lifetime).timeout

	queue_free()


func _apply_visual_variation() -> void:
	if sprite:
		sprite.scale = Vector2(var_scale, var_scale)
	if col:
		col.scale = Vector2(var_scale, var_scale)
	if _mat != null:
		_mat.set_shader_parameter("sat_mul", var_saturation)
	if explosion:
		explosion.scale = Vector2(var_scale, var_scale)
		explosion.self_modulate = explosion_color_small.lerp(explosion_color_big, _size_t)
