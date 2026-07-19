extends Node2D
class_name FlightShell

@onready var director_container: Node = $DirectorContainer


func install_director(director_scene: PackedScene) -> Node:
	for child in director_container.get_children():
		child.queue_free()
	var director := director_scene.instantiate()
	director_container.add_child(director)
	return director
