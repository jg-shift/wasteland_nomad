extends DamageModifier
class_name CraftUpgradeState

signal weapon_damage_changed(upgrade: int)

var _weapon_damage_upgrade: int = 0


func apply(initial_damage: int) -> int:
	return initial_damage + (_weapon_damage_upgrade * initial_damage)


func calculate_weapon_damage(initial_damage: int) -> int:
	return apply(initial_damage)


func get_weapon_damage_upgrade() -> int:
	return _weapon_damage_upgrade


func add_weapon_damage_upgrade(amount: int) -> void:
	if amount <= 0:
		return
	_weapon_damage_upgrade += amount
	weapon_damage_changed.emit(_weapon_damage_upgrade)
