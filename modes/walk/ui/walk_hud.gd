extends CanvasLayer
class_name WalkHUD

@onready var health_display: ProgressBar = $Root/TopLeft/Content/HealthDisplay
@onready var objective_display: Label = $Root/TopLeft/Content/ObjectiveDisplay
@onready var repair_material_display: Label = $Root/TopLeft/Content/RepairMaterialDisplay
@onready var interaction_prompt: Label = $Root/BottomCenter/InteractionPrompt
@onready var tutorial_message: Label = $Root/Center/TutorialMessage


func set_health(current: int, maximum: int) -> void:
	health_display.max_value = maxi(1, maximum)
	health_display.value = clampi(current, 0, maximum)


func set_objective(objective: String) -> void:
	objective_display.text = objective


func set_repair_materials(current: int, required: int) -> void:
	repair_material_display.text = "REPAIR PARTS: %d / %d" % [current, required]


func set_interaction_prompt(prompt: String) -> void:
	interaction_prompt.text = prompt
	interaction_prompt.visible = not prompt.is_empty()


func show_tutorial_message(message: String) -> void:
	tutorial_message.text = message
	tutorial_message.visible = not message.is_empty()
