extends Node2D
class_name WeaponMachinegunSimple

@export var enabled: bool = true
@export var damage: int = 1
@export var bullet_speed: float = 900.0
@export var fire_rate: float = 12.0

@onready var muzzle: Marker2D = $Muzzle
@onready var bullet_template: Area2D = $Bullet

var _shooting: bool = false
var _fire_timer: Timer
var _last_ctx: Dictionary = {}

func _ready() -> void:
	# Шаблон пули: просто прячем и выключаем коллизию/процесс
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

	_update_timer_period()

func _update_timer_period() -> void:
	fire_rate = maxf(0.1, fire_rate)
	_fire_timer.wait_time = 1.0 / fire_rate

func trigger_push(ctx: Dictionary = {}) -> void:
	if _shooting or not enabled:
		return
	_last_ctx = ctx
	_shooting = true
	_update_timer_period()

	_spawn_bullet()
	_fire_timer.start()

func trigger_release(_ctx: Dictionary = {}) -> void:
	_shooting = false
	_fire_timer.stop()

func _on_fire_tick() -> void:
	if not _shooting:
		_fire_timer.stop()
		return
	_spawn_bullet()

func _spawn_bullet() -> void:
	var b: Area2D = bullet_template.duplicate() as Area2D

	# enable copy
	b.visible = true
	b.set_process(true)
	b.set_physics_process(true)

	var cs := b.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs: cs.disabled = false

	# IMPORTANT: parent to Bullets (world), not to the gun/player
	var bullets_root := _get_bullets_root()
	bullets_root.add_child(b)
	b.global_position = muzzle.global_position


	# place in world coords
	b.global_position = muzzle.global_position
	b.global_rotation = muzzle.global_rotation

	if b is Bullet:
		var bb := b as Bullet
		bb.damage = damage
		bb.speed = bullet_speed
		

func _get_bullets_root() -> Node2D:
	# текущая запущенная сцена (Flight)
	var root := get_tree().current_scene
	var bullets := root.get_node_or_null("Bullets") as Node2D
	if bullets == null:
		# на всякий случай создадим
		bullets = Node2D.new()
		bullets.name = "Bullets"
		root.add_child(bullets)
	return bullets
