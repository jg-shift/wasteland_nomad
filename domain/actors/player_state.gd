extends RefCounted
class_name PlayerState

var health: HealthState = HealthState.new(100)
var equipped_weapon_ids: Array[StringName] = []
