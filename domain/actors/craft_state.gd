extends RefCounted
class_name CraftState

var health: HealthState = HealthState.new(100)
var upgrades: CraftUpgradeState = CraftUpgradeState.new()
var fuel_tank: FuelTankState = FuelTankState.new()
var installed_weapon_ids: Array[StringName] = []
