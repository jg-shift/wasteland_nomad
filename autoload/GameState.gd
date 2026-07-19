extends Node
## Persistent game-state façade.
## Domain behavior lives in focused state models under res://autoload/state/.

signal game_mode_changed(mode: int)
signal player_hp_changed(new_hp: int, max_hp: int)
signal player_damage_taken(amount: int)
signal player_died
signal craft_hp_changed(new_hp: int, max_hp: int)
signal craft_damage_taken(amount: int)
signal craft_destroyed
signal craft_weapon_damage_upgrade_changed(upgrade: int)
signal points_changed(points: int)
signal flight_progress_changed(progress: float)
signal skill_unlocked(id: String)
signal skill_upgraded(id: String, new_level: int)

enum GameMode {
	HUB,
	ON_FOOT,
	FLIGHT,
}

var game_mode := GameModeState.new(GameMode.HUB)
var player_health := HealthState.new(100)
var craft_health := HealthState.new(100)
var craft_upgrades := CraftUpgradeState.new()
var score := ScoreState.new()
var flight_progress := FlightProgressState.new()
var skills := SkillBook.new()


func _ready() -> void:
	game_mode.changed.connect(_on_game_mode_changed)
	player_health.changed.connect(_on_player_hp_changed)
	player_health.damage_taken.connect(_on_player_damage_taken)
	player_health.depleted.connect(_on_player_died)
	craft_health.changed.connect(_on_craft_hp_changed)
	craft_health.damage_taken.connect(_on_craft_damage_taken)
	craft_health.depleted.connect(_on_craft_destroyed)
	craft_upgrades.weapon_damage_changed.connect(_on_craft_weapon_damage_changed)
	score.changed.connect(_on_points_changed)
	flight_progress.changed.connect(_on_flight_progress_changed)
	skills.unlocked.connect(_on_skill_unlocked)
	skills.upgraded.connect(_on_skill_upgraded)


func get_game_mode() -> int:
	return game_mode.get_mode()


func set_game_mode(mode: int) -> void:
	game_mode.set_mode(mode)


func enter_hub() -> void:
	set_game_mode(GameMode.HUB)


func enter_on_foot() -> void:
	set_game_mode(GameMode.ON_FOOT)


func enter_flight() -> void:
	set_game_mode(GameMode.FLIGHT)


func get_player_hp() -> int:
	return player_health.get_hp()


func get_player_max_hp() -> int:
	return player_health.get_max_hp()


func take_player_damage(amount: int) -> void:
	player_health.take_damage(amount)


func heal_player(amount: int) -> void:
	player_health.heal(amount)


func set_player_max_hp(value: int) -> void:
	player_health.set_max_hp(value)


func reset_player_hp() -> void:
	player_health.reset()


func get_craft_hp() -> int:
	return craft_health.get_hp()


func get_craft_max_hp() -> int:
	return craft_health.get_max_hp()


func take_craft_damage(amount: int) -> void:
	craft_health.take_damage(amount)


func heal_craft(amount: int) -> void:
	craft_health.heal(amount)


func set_craft_max_hp(value: int) -> void:
	craft_health.set_max_hp(value)


func reset_craft_hp() -> void:
	craft_health.reset()


func add_craft_max_hp(amount: int) -> void:
	craft_health.add_max_hp(amount)


func get_craft_weapon_damage(initial_damage: int) -> int:
	return craft_upgrades.calculate_weapon_damage(initial_damage)


func get_craft_weapon_damage_upgrade() -> int:
	return craft_upgrades.get_weapon_damage_upgrade()


func add_craft_weapon_damage_upgrade(amount: int) -> void:
	craft_upgrades.add_weapon_damage_upgrade(amount)


# Compatibility aliases for callers that treat craft health as the default health.
func get_hp() -> int:
	return get_craft_hp()


func get_max_hp() -> int:
	return get_craft_max_hp()


func take_damage(amount: int) -> void:
	take_craft_damage(amount)


func heal(amount: int) -> void:
	heal_craft(amount)


func set_max_hp(value: int) -> void:
	set_craft_max_hp(value)


func reset_hp() -> void:
	reset_craft_hp()


func get_points() -> int:
	return score.get_points()


func set_points(value: int) -> void:
	score.set_points(value)


func add_points(amount: int) -> void:
	score.add_points(amount)


func reset_points() -> void:
	score.reset()


func _on_enemy_died(victory_points: int) -> void:
	add_points(victory_points)


func get_flight_progress() -> float:
	return flight_progress.get_progress()


func set_flight_progress(progress: float) -> void:
	flight_progress.set_progress(progress)


func reset_flight_progress() -> void:
	flight_progress.reset()


func is_skill_unlocked(id: String) -> bool:
	return skills.is_unlocked(id)


func get_skill_level(id: String) -> int:
	return skills.get_level(id)


func unlock_skill(id: String) -> void:
	skills.unlock(id)


func upgrade_skill(id: String) -> void:
	skills.upgrade(id)


func get_all_skills() -> Dictionary:
	return skills.get_all()


func _on_game_mode_changed(mode: int) -> void:
	game_mode_changed.emit(mode)


func _on_player_hp_changed(new_hp: int, max_hp: int) -> void:
	player_hp_changed.emit(new_hp, max_hp)


func _on_player_damage_taken(amount: int) -> void:
	player_damage_taken.emit(amount)


func _on_player_died() -> void:
	player_died.emit()


func _on_craft_hp_changed(new_hp: int, max_hp: int) -> void:
	craft_hp_changed.emit(new_hp, max_hp)


func _on_craft_damage_taken(amount: int) -> void:
	craft_damage_taken.emit(amount)


func _on_craft_destroyed() -> void:
	craft_destroyed.emit()


func _on_craft_weapon_damage_changed(upgrade: int) -> void:
	craft_weapon_damage_upgrade_changed.emit(upgrade)


func _on_points_changed(points: int) -> void:
	points_changed.emit(points)


func _on_flight_progress_changed(progress: float) -> void:
	flight_progress_changed.emit(progress)


func _on_skill_unlocked(id: String) -> void:
	skill_unlocked.emit(id)


func _on_skill_upgraded(id: String, new_level: int) -> void:
	skill_upgraded.emit(id, new_level)
