extends Node2D
class_name WalkShell

@export var initial_level: PackedScene

@onready var level_container: Node2D = $LevelContainer


func _ready() -> void:
	if initial_level != null:
		load_level(initial_level)


func load_level(level_scene: PackedScene) -> Node:
	for child in level_container.get_children():
		child.queue_free()
	var level := level_scene.instantiate()
	level_container.add_child(level)
	return level
