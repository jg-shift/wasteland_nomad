extends Node

@export var enemy_spawner: EnemySpawner
@export var player: PlayerCraft


func _ready() -> void:
	if enemy_spawner == null:
		push_error("FlightStateBindings: assign enemy_spawner in the Inspector")
		return
	if player == null:
		push_error("FlightStateBindings: assign player in the Inspector")
		return

	enemy_spawner.enemy_died.connect(_on_enemy_died)
	enemy_spawner.collision_damage_requested.connect(_on_collision_damage_requested)

	player.set_weapon_damage_modifier(GameState.craft_upgrades)


func _on_enemy_died(victory_points: int) -> void:
	GameState.add_points(victory_points)


func _on_collision_damage_requested(amount: int) -> void:
	GameState.take_craft_damage(amount)
