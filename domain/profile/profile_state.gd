extends RefCounted
class_name ProfileState

signal prologue_completed_changed(completed: bool)
signal currency_changed(currency: int)
signal location_discovered(location_id: StringName)

var skills: SkillBook = SkillBook.new()
var location_states: Dictionary = {}

var _prologue_completed: bool = false
var _currency: int = 0
var _discovered_location_ids: Array[StringName] = []


func is_prologue_completed() -> bool:
	return _prologue_completed


func complete_prologue() -> void:
	if _prologue_completed:
		return
	_prologue_completed = true
	prologue_completed_changed.emit(true)


func get_currency() -> int:
	return _currency


func set_currency(value: int) -> void:
	var new_currency := maxi(0, value)
	if _currency == new_currency:
		return
	_currency = new_currency
	currency_changed.emit(_currency)


func add_currency(amount: int) -> void:
	if amount <= 0:
		return
	set_currency(_currency + amount)


func discover_location(location_id: StringName) -> void:
	if location_id.is_empty() or _discovered_location_ids.has(location_id):
		return
	_discovered_location_ids.append(location_id)
	location_discovered.emit(location_id)


func is_location_discovered(location_id: StringName) -> bool:
	return _discovered_location_ids.has(location_id)


func get_discovered_location_ids() -> Array[StringName]:
	return _discovered_location_ids.duplicate()
