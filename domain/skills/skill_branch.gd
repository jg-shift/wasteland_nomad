extends RefCounted
class_name SkillBranch
## Shared branch identifiers for the progression system.
## Both passive perks and active skills belong to exactly one branch.
## Design source: obsidian notes 14 (passive perks) and 15 (active skills).

enum Type {
	CRAFT,
	PILOT,
}


static func is_valid_type(value: int) -> bool:
	return value >= 0 and value < Type.size()
