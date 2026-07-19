extends RefCounted
class_name HealthState

signal changed(new_hp: int, max_hp: int)
signal damage_taken(amount: int)
signal depleted

var _hp: int
var _max_hp: int
var _is_depleted: bool = false


func _init(initial_max_hp: int = 100) -> void:
	_max_hp = maxi(1, initial_max_hp)
	_hp = _max_hp


func get_hp() -> int:
	return _hp


func get_max_hp() -> int:
	return _max_hp


func take_damage(amount: int) -> void:
	if _is_depleted:
		return
	var damage := maxi(0, amount)
	if damage <= 0:
		return
	_hp = clampi(_hp - damage, 0, _max_hp)
	damage_taken.emit(damage)
	changed.emit(_hp, _max_hp)
	if _hp == 0:
		_is_depleted = true
		depleted.emit()


func heal(amount: int) -> void:
	if _is_depleted:
		return
	_hp = clampi(_hp + amount, 0, _max_hp)
	changed.emit(_hp, _max_hp)


func set_max_hp(value: int) -> void:
	_max_hp = maxi(1, value)
	_hp = clampi(_hp, 0, _max_hp)
	changed.emit(_hp, _max_hp)


func add_max_hp(amount: int) -> void:
	if amount <= 0:
		return
	set_max_hp(_max_hp + amount)


func reset() -> void:
	_is_depleted = false
	_hp = _max_hp
	changed.emit(_hp, _max_hp)
