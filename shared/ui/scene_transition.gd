extends CanvasLayer
class_name SceneTransition

@onready var location_label: Label = $Root/Center/Content/LocationLabel
@onready var status_label: Label = $Root/Center/Content/StatusLabel
@onready var loading_indicator: ProgressBar = $Root/Center/Content/LoadingIndicator


func show_transition(location: String, status: String = "") -> void:
	location_label.text = location
	status_label.text = status
	loading_indicator.value = 0.0
	show()


func set_progress(progress: float) -> void:
	loading_indicator.value = clampf(progress, 0.0, 1.0) * 100.0


func hide_transition() -> void:
	hide()
