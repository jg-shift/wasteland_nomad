# res://player/Player.gd
extends CharacterBody2D
class_name PlayerCraft

@onready var weapon_slots: Node = $WeaponSlots
@export var padding: float = 16.0

## Base max speed at minimum flight_speed (feels light and responsive)
@export var max_speed: float = 520.0

## How much max_speed is reduced at maximum flight_speed (0.45 = 55% slower)
@export var speed_penalty_at_max: float = 0.45

@export var accel: float = 2200.0
@export var decel: float = 2600.0

func _physics_process(delta: float) -> void:
	var input := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	)

	if input.length_squared() > 1.0:
		input = input.normalized()

	# Higher flight_speed = heavier, harder to control
	var speed_factor := lerpf(1.0, speed_penalty_at_max, WorldUtils.flight_speed)
	var target_vel := input * max_speed * speed_factor
	var rate := (accel if input != Vector2.ZERO else decel) * speed_factor

	velocity = velocity.move_toward(target_vel, rate * delta)
	move_and_slide()

	# Constrain to bottom half of screen — use world_view_rect for correct coords in Web/stretch
	var rect: Rect2 = WorldUtils.world_view_rect(get_viewport())
	var left     := rect.position.x + padding
	var right    := rect.position.x + rect.size.x - padding
	var mid_y    := rect.position.y + rect.size.y * 0.5 + padding
	var bottom_y := rect.position.y + rect.size.y - padding

	global_position.x = clampf(global_position.x, left, right)
	global_position.y = clampf(global_position.y, mid_y, bottom_y)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		_broadcast_weapon_trigger(true)
	elif event.is_action_released("fire"):
		_broadcast_weapon_trigger(false)

func _broadcast_weapon_trigger(pressed: bool) -> void:
	var context := WeaponContext.new(self, 1)
	for child in weapon_slots.get_children():
		var weapon := child as WeaponBase
		if weapon == null:
			continue
		if pressed:
			weapon.trigger_push(context)
		else:
			weapon.trigger_release(context)


func set_weapon_damage_modifier(modifier: DamageModifier) -> void:
	for child in weapon_slots.get_children():
		var weapon := child as WeaponBase
		if weapon != null:
			weapon.set_damage_modifier(modifier)
