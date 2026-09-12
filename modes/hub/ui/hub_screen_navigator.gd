extends Node
class_name HubScreenNavigator

enum Screen {
	CENTRAL,
	GAS_STATION,
	REPAIR_STATION,
	WORKSHOP,
	NPC_LIST,
	DIALOGUE,
	EXPEDITION_PLANNING,
}

signal screen_changed(screen: Screen)

@export var central_screen: Control
@export var gas_station_screen: Control
@export var repair_station_screen: Control
@export var workshop_screen: Control
@export var npc_list_screen: Control
@export var dialogue_screen: Control
@export var expedition_planning_screen: Control

var current_screen: Screen = Screen.CENTRAL
var _screens: Dictionary = {}
var _history: Array[int] = []


func _ready() -> void:
	_screens = {
		Screen.CENTRAL: central_screen,
		Screen.GAS_STATION: gas_station_screen,
		Screen.REPAIR_STATION: repair_station_screen,
		Screen.WORKSHOP: workshop_screen,
		Screen.NPC_LIST: npc_list_screen,
		Screen.DIALOGUE: dialogue_screen,
		Screen.EXPEDITION_PLANNING: expedition_planning_screen,
	}

	for screen in _screens.values():
		if screen == null:
			push_error("HubScreenNavigator: assign every Hub screen")
			return

	open_central()


func open_screen(screen: Screen, remember_current: bool = true) -> void:
	if not _screens.has(screen):
		push_error("HubScreenNavigator: unknown screen ID %d" % screen)
		return
	if screen == current_screen:
		return
	if remember_current:
		_history.append(current_screen)
	_show_screen(screen)


func open_central() -> void:
	_history.clear()
	_show_screen(Screen.CENTRAL)


func go_back() -> void:
	if _history.is_empty():
		open_central()
		return
	var previous_screen: int = _history.pop_back()
	_show_screen(previous_screen)


func _show_screen(screen: Screen) -> void:
	for screen_id in _screens:
		var screen_node := _screens[screen_id] as Control
		screen_node.visible = screen_id == screen
	current_screen = screen
	screen_changed.emit(current_screen)
