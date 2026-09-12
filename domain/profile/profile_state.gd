extends RefCounted
class_name ProfileState

signal prologue_completed_changed(completed: bool)
signal currency_changed(currency: int)
signal location_discovered(location_id: StringName)
signal perk_acquired(perk_id: StringName)
signal active_skill_selected(branch: SkillBranch.Type, skill_id: StringName)

var location_states: Dictionary = {}
var acquired_perk_ids: Array[StringName] = []

var _selected_active_skill_ids: Dictionary = {}

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


func has_perk(perk_id: StringName) -> bool:
	return acquired_perk_ids.has(perk_id)


## Records perk ownership. Business rules (price, availability) live in
## application/skills/perk_purchase_service.gd — this guard is only against
## duplicates and empty ids.
func acquire_perk(perk_id: StringName) -> bool:
	if perk_id.is_empty() or acquired_perk_ids.has(perk_id):
		return false
	acquired_perk_ids.append(perk_id)
	perk_acquired.emit(perk_id)
	return true


func get_selected_active_skill(branch: SkillBranch.Type) -> StringName:
	return _selected_active_skill_ids.get(branch, &"")


## Records the pre-flight loadout choice for one branch. Catalog validation
## (skill exists, branch matches) lives in
## application/skills/active_skill_loadout_service.gd.
func set_selected_active_skill(
	branch: SkillBranch.Type,
	skill_id: StringName
) -> void:
	if _selected_active_skill_ids.get(branch, &"") == skill_id:
		return
	_selected_active_skill_ids[branch] = skill_id
	active_skill_selected.emit(branch, skill_id)
