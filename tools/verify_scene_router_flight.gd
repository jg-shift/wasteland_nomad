extends Node


func _ready() -> void:
	var tree := get_tree()
	var exit_timer := tree.create_timer(2.0)
	exit_timer.timeout.connect(tree.quit)
	SceneRouter.start_flight(10.0, 1.0)
