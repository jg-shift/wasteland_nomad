extends RefCounted
class_name SkillBook

signal unlocked(id: String)
signal upgraded(id: String, new_level: int)

var _skills: Dictionary = {}


func is_unlocked(id: String) -> bool:
	return _skills.get(id, {}).get("unlocked", false)


func get_level(id: String) -> int:
	return _skills.get(id, {}).get("level", 0)


func unlock(id: String) -> void:
	if is_unlocked(id):
		return
	_skills[id] = {"unlocked": true, "level": 1}
	unlocked.emit(id)


func upgrade(id: String) -> void:
	if not is_unlocked(id):
		push_warning("SkillBook: cannot upgrade locked skill '%s'" % id)
		return
	_skills[id]["level"] += 1
	upgraded.emit(id, _skills[id]["level"])


func get_all() -> Dictionary:
	return _skills.duplicate(true)
