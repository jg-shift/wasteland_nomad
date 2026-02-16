extends Area2D
class_name Bullet

@export var speed: float = 900.0
@export var kill_margin_px: float = 100.0
@export var bullets_root: Node2D

var damage: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position.y -= speed * delta

	var rect := _world_view_rect()
	if global_position.y < rect.position.y - kill_margin_px:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("receive_damage"):
		body.call("receive_damage", damage)
	queue_free()

func _world_view_rect() -> Rect2:
	var vp := get_viewport().get_visible_rect()
	var cx := get_viewport().get_canvas_transform()
	var tl := cx.affine_inverse() * vp.position
	var br := cx.affine_inverse() * (vp.position + vp.size)
	return Rect2(tl, br - tl)
