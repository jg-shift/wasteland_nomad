extends SceneTree

const SCENES: PackedStringArray = [
	"res://modes/flight/flight.tscn",
	"res://modes/flight/directors/prologue_director.tscn",
	"res://shared/ui/scene_transition.tscn",
	"res://modes/walk/walk.tscn",
	"res://modes/walk/actors/player_character.tscn",
	"res://gameplay/vehicles/crashed_craft.tscn",
	"res://modes/walk/levels/crash_sites/tutorial_crash_site.tscn",
	"res://modes/walk/ui/walk_hud.tscn",
	"res://modes/hub/hub.tscn",
	"res://modes/hub/locations/first_hub.tscn",
]


func _initialize() -> void:
	_verify_scenes.call_deferred()


func _verify_scenes() -> void:
	for scene_path in SCENES:
		var packed := load(scene_path) as PackedScene
		assert(packed != null, "Cannot load scene: %s" % scene_path)

		var instance := packed.instantiate()
		assert(instance != null, "Cannot instantiate scene: %s" % scene_path)
		root.add_child(instance)
		current_scene = instance
		await process_frame
		instance.queue_free()
		await process_frame

	print("Upgrade scene smoke test: %d scenes OK" % SCENES.size())
	quit()
