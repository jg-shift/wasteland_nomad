extends SceneTree


class PhysicsTransitionTrigger:
	extends Node

	var requested: bool = false

	func _physics_process(_delta: float) -> void:
		if requested:
			return
		requested = true
		SceneRouter.change_scene_to_file("res://scenes/shop_beta.tscn")


func _initialize() -> void:
	var flight := load("res://scenes/demo_Scene/node_2d.tscn").instantiate()
	root.add_child(flight)
	current_scene = flight
	root.add_child(PhysicsTransitionTrigger.new())

	var timeout := create_timer(2.0)
	timeout.timeout.connect(quit)
