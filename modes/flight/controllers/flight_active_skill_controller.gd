extends Node
class_name FlightActiveSkillController
## Scene-local runtime for the selected CRAFT active skill (obsidian note 15).
## Owns input handling, cooldown, and the timed effect — never persistent
## state: the loadout choice lives in GameSession.profile.
##
## Behavior strategy by ActiveSkillDefinition.kind:
## - afterburner: temporary world-scroll boost via WorldUtils.
## - napalm_blast: emits skill_activated only; the combat consumer (enemy
##   spawner / damageable bodies) is not wired yet.


const AFTERBURNER_BOOST_MULTIPLIER := 1.5

signal skill_activated(definition: ActiveSkillDefinition)
signal cooldown_finished

@export var input_action: StringName = &"active_skill"

var _definition: ActiveSkillDefinition
var _cooldown_remaining_sec: float = 0.0
var _effect_remaining_sec: float = 0.0


func _ready() -> void:
	_definition = ActiveSkillLoadoutService.get_selected_definition(
		SkillBranch.Type.CRAFT
	)
	if _definition == null:
		push_warning(
			"FlightActiveSkillController: no craft active skill selected"
		)


func _process(delta: float) -> void:
	if _effect_remaining_sec > 0.0:
		_effect_remaining_sec = maxf(0.0, _effect_remaining_sec - delta)
		if _effect_remaining_sec == 0.0:
			_end_effect()

	if _cooldown_remaining_sec > 0.0:
		_cooldown_remaining_sec = maxf(0.0, _cooldown_remaining_sec - delta)
		if _cooldown_remaining_sec == 0.0:
			cooldown_finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if _definition == null:
		return
	if event.is_action_pressed(input_action):
		try_activate()


func is_ready_to_activate() -> bool:
	return (
		_definition != null
		and _cooldown_remaining_sec == 0.0
		and _effect_remaining_sec == 0.0
	)


func try_activate() -> bool:
	if not is_ready_to_activate():
		return false

	_effect_remaining_sec = _definition.duration_sec
	_cooldown_remaining_sec = _definition.cooldown_sec
	_begin_effect()
	skill_activated.emit(_definition)
	return true


func _begin_effect() -> void:
	if _definition.kind == ActiveSkillDefinition.KIND_AFTERBURNER:
		WorldUtils.set_flight_boost_multiplier(AFTERBURNER_BOOST_MULTIPLIER)


func _end_effect() -> void:
	if _definition.kind == ActiveSkillDefinition.KIND_AFTERBURNER:
		WorldUtils.set_flight_boost_multiplier(1.0)


func _exit_tree() -> void:
	WorldUtils.set_flight_boost_multiplier(1.0)
