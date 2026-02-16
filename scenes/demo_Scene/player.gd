# res://player/Player.gd
extends CharacterBody2D

@onready var weapon_slots: Node = $WeaponSlots
@export var speed: float = 450.0
@export var padding: float = 16.0 # отступ от края (примерно радиус корабля)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		_broadcast_weapon_trigger(true)
	elif event.is_action_released("fire"):
		_broadcast_weapon_trigger(false)

func _broadcast_weapon_trigger(pressed: bool) -> void:
	# Контекст можно расширять: кто стреляет, откуда, множители урона и т.п.
	var ctx := {
		"owner": self,
		"team": 1, # пример
	}

	for w in weapon_slots.get_children():
		if pressed:
			if w.has_method("trigger_push"):
				w.call("trigger_push", ctx)
		else:
			if w.has_method("trigger_release"):
				w.call("trigger_release", ctx)

func _physics_process(delta: float) -> void:
	# движение
	var input := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	).normalized()

	velocity = input * speed
	move_and_slide()

	# ограничения в нижней половине экрана
	var rect: Rect2 = get_viewport().get_visible_rect() # (0,0)-(w,h) в экранных координатах
	var left  := rect.position.x + padding
	var right := rect.position.x + rect.size.x - padding

	var mid_y := rect.position.y + rect.size.y * 0.5 + padding
	var bottom_y := rect.position.y + rect.size.y - padding

	global_position.x = clampf(global_position.x, left, right)
	global_position.y = clampf(global_position.y, mid_y, bottom_y)
