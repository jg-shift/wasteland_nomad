extends Node
class_name PrologueDirector

signal tutorial_message_requested(message: String)
signal attack_requested
signal crash_requested

@export var opening_message: String = "Keep the craft moving."
@export var attack_delay_sec: float = 8.0
@export var crash_delay_sec: float = 4.0
@export var auto_start: bool = false

@onready var attack_timer: Timer = $AttackTimer
@onready var crash_timer: Timer = $CrashTimer

var _started: bool = false


func _ready() -> void:
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	crash_timer.timeout.connect(_on_crash_timer_timeout)
	if auto_start:
		start()


func start() -> void:
	if _started:
		return
	_started = true
	tutorial_message_requested.emit(opening_message)
	attack_timer.start(maxf(0.01, attack_delay_sec))


func _on_attack_timer_timeout() -> void:
	attack_requested.emit()
	crash_timer.start(maxf(0.01, crash_delay_sec))


func _on_crash_timer_timeout() -> void:
	crash_requested.emit()
