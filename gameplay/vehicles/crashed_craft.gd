extends Node2D
class_name CrashedCraft

signal repair_started
signal repair_completed
signal resume_requested

enum RepairState {
	DISABLED,
	REPAIRABLE,
	REPAIRING,
	REPAIRED,
	READY_TO_RESUME,
}

@export var repair_state: RepairState = RepairState.DISABLED


func make_repairable() -> void:
	if repair_state != RepairState.DISABLED:
		return
	repair_state = RepairState.REPAIRABLE


func begin_repair() -> void:
	if repair_state != RepairState.REPAIRABLE:
		return
	repair_state = RepairState.REPAIRING
	repair_started.emit()


func complete_repair() -> void:
	if repair_state != RepairState.REPAIRING:
		return
	repair_state = RepairState.REPAIRED
	repair_completed.emit()
	repair_state = RepairState.READY_TO_RESUME


func request_resume() -> void:
	if repair_state == RepairState.READY_TO_RESUME:
		resume_requested.emit()
