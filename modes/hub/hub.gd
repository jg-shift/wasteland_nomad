extends Node2D
class_name HubShell

@export var initial_location: PackedScene

@onready var location_container: Node2D = $LocationContainer
@onready var location_name_label: Label = $UI/HubHUD/LocationName


func _ready() -> void:
	GameState.enter_hub()

	var current_location := WorldLocations.find_location(
		GameSession.current_location_id
	)
	if (
		current_location != null
		and current_location.location_type == LocationDefinition.LocationType.HUB
		and current_location.content_scene != null
	):
		load_location(current_location.content_scene)
		location_name_label.text = current_location.display_name.to_upper()
		return

	if initial_location != null:
		load_location(initial_location)


func load_location(location_scene: PackedScene) -> Node:
	for child in location_container.get_children():
		child.queue_free()
	var location := location_scene.instantiate()
	location_container.add_child(location)
	return location
