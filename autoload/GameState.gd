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

enum GameMode {
	HUB,
	ON_FOOT,
	FLIGHT,
}

var game_mode := GameModeState.new(GameMode.HUB)
var flight_progress := FlightProgressState.new()
var _legacy_score := ScoreState.new()

var score: ScoreState:
	get:
		if GameSession.active_expedition != null:
			return GameSession.active_expedition.score
		return _legacy_score

var player_health: HealthState:
	get:
		return GameSession.player.health

var craft_health: HealthState:
	get:
		return GameSession.craft.health

var craft_upgrades: CraftUpgradeState:
	get:
		return GameSession.craft.upgrades

var _bound_player_health: HealthState
var _bound_craft_health: HealthState
var _bound_craft_upgrades: CraftUpgradeState
var _bound_score: ScoreState


func _ready() -> void:
	GameSession.state_models_replaced.connect(_on_session_models_replaced)
	GameSession.expedition_started.connect(_on_expedition_changed)
	GameSession.expedition_cleared.connect(_on_expedition_changed)
	game_mode.changed.connect(_on_game_mode_changed)
	flight_progress.changed.connect(_on_flight_progress_changed)
	_bind_session_models()


func _bind_session_models() -> void:
	_unbind_session_models()

	_bound_player_health = player_health
	_bound_craft_health = craft_health
	_bound_craft_upgrades = craft_upgrades
	_bound_score = score

	_bound_player_health.changed.connect(_on_player_hp_changed)
	_bound_player_health.damage_taken.connect(_on_player_damage_taken)
	_bound_player_health.depleted.connect(_on_player_died)
	_bound_craft_health.changed.connect(_on_craft_hp_changed)
	_bound_craft_health.damage_taken.connect(_on_craft_damage_taken)
	_bound_craft_health.depleted.connect(_on_craft_destroyed)
	_bound_craft_upgrades.weapon_damage_changed.connect(_on_craft_weapon_damage_changed)
	_bound_score.changed.connect(_on_points_changed)


func _unbind_session_models() -> void:
	if _bound_player_health != null:
		if _bound_player_health.changed.is_connected(_on_player_hp_changed):
			_bound_player_health.changed.disconnect(_on_player_hp_changed)
		if _bound_player_health.damage_taken.is_connected(_on_player_damage_taken):
			_bound_player_health.damage_taken.disconnect(_on_player_damage_taken)
		if _bound_player_health.depleted.is_connected(_on_player_died):
			_bound_player_health.depleted.disconnect(_on_player_died)

	if _bound_craft_health != null:
		if _bound_craft_health.changed.is_connected(_on_craft_hp_changed):
			_bound_craft_health.changed.disconnect(_on_craft_hp_changed)
		if _bound_craft_health.damage_taken.is_connected(_on_craft_damage_taken):
			_bound_craft_health.damage_taken.disconnect(_on_craft_damage_taken)
		if _bound_craft_health.depleted.is_connected(_on_craft_destroyed):
			_bound_craft_health.depleted.disconnect(_on_craft_destroyed)

	if (
		_bound_craft_upgrades != null
		and _bound_craft_upgrades.weapon_damage_changed.is_connected(
			_on_craft_weapon_damage_changed
		)
	):
		_bound_craft_upgrades.weapon_damage_changed.disconnect(
			_on_craft_weapon_damage_changed
		)

	if _bound_score != null and _bound_score.changed.is_connected(_on_points_changed):
		_bound_score.changed.disconnect(_on_points_changed)


func _on_session_models_replaced() -> void:
	var previous_points := (
		_bound_score.get_points() if _bound_score != null else get_points()
	)
	_bind_session_models()
	if get_points() != previous_points:
		points_changed.emit(get_points())


func _on_expedition_changed(_expedition: ExpeditionState) -> void:
	var previous_points := (
		_bound_score.get_points() if _bound_score != null else get_points()
	)
	if _bound_score != null and _bound_score.changed.is_connected(_on_points_changed):
		_bound_score.changed.disconnect(_on_points_changed)
	_bound_score = score
	_bound_score.changed.connect(_on_points_changed)
	if get_points() != previous_points:
		points_changed.emit(get_points())


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
