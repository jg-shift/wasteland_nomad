extends Node2D
class_name HubShell

@export var initial_location: PackedScene

@onready var location_container: Node2D = $LocationContainer


func _ready() -> void:
	if initial_location != null:
		load_location(initial_location)


func load_location(location_scene: PackedScene) -> Node:
	for child in location_container.get_children():
		child.queue_free()
	var location := location_scene.instantiate()
	location_container.add_child(location)
	return location
