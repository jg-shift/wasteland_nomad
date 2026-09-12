extends RefCounted
class_name ExpeditionState

var expedition_id: StringName
var score: ScoreState = ScoreState.new()
var unsecured_loot: Array[Dictionary] = []
var temporary_modifiers: Dictionary = {}


func _init(p_expedition_id: StringName = &"") -> void:
	expedition_id = p_expedition_id
