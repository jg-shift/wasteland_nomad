extends WeaponBase
class_name WeaponMachinegunSimple

@export var enabled: bool = true
@export var damage: int = 1
@export var bullet_speed: float = 900.0
@export var fire_rate: float = 12.0

@onready var muzzle: Marker2D = $Muzzle
@onready var bullet_template: Area2D = $Bullet

var _shooting: bool = false
var _fire_timer: Timer
var _bullets_root: Node2D  # cached on first use
var _damage_modifier: DamageModifier


func _ready() -> void:
	bullet_template.visible = false
	bullet_template.set_process(false)
	bullet_template.set_physics_process(false)

	var cs: CollisionShape2D = bullet_template.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs != null:
		cs.disabled = true

	_fire_timer = Timer.new()
	_fire_timer.one_shot = false
	add_child(_fire_timer)
	_fire_timer.timeout.connect(_on_fire_tick)
	_fire_timer.wait_time = 1.0 / maxf(0.1, fire_rate)


func trigger_push(_context: WeaponContext) -> void:
	if _shooting or not enabled:
		return
	_shooting = true
	_fire_timer.wait_time = 1.0 / maxf(0.1, fire_rate)

	_spawn_bullet()
	_fire_timer.start()


func trigger_release(_context: WeaponContext) -> void:
	_shooting = false
	_fire_timer.stop()


func set_damage_modifier(modifier: DamageModifier) -> void:
	_damage_modifier = modifier


func _on_fire_tick() -> void:
	if not _shooting:
		_fire_timer.stop()
		return
	_spawn_bullet()


func _spawn_bullet() -> void:
	var b := bullet_template.duplicate() as Area2D

	b.visible = true
	b.set_process(true)
	b.set_physics_process(true)

	var cs := b.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs: cs.disabled = false

	_get_bullets_root().add_child(b)

	# Position and rotation from muzzle — bullet will fly along its local -Y axis
	b.global_position = muzzle.global_position
	b.global_rotation = muzzle.global_rotation

	if b is Bullet:
		(b as Bullet).damage = _modified_damage()
		(b as Bullet).speed  = bullet_speed


func _get_bullets_root() -> Node2D:
	if is_instance_valid(_bullets_root):
		return _bullets_root
	var root := get_tree().current_scene
	var bullets := root.get_node_or_null("Bullets") as Node2D
	if bullets == null:
		bullets = Node2D.new()
		bullets.name = "Bullets"
		root.add_child(bullets)
	_bullets_root = bullets
	return _bullets_root


func _modified_damage() -> int:
	if _damage_modifier == null:
		return damage
	return _damage_modifier.apply(damage)
