extends Area2D
class_name Bullet

@export var speed: float = 900.0
@export var kill_margin_px: float = 100.0

var damage: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move along local -Y axis, respecting rotation set by the weapon's muzzle
	global_position += -transform.y * speed * delta

	var rect := WorldUtils.world_view_rect(get_viewport())
	if global_position.y < rect.position.y - kill_margin_px:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body is DamageableBody2D:
		(body as DamageableBody2D).receive_damage(damage)
	queue_free()
