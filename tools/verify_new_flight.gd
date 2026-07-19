extends SceneTree


func _initialize() -> void:
	_verify.call_deferred()


func _verify() -> void:
	var packed := load("res://modes/flight/flight.tscn") as PackedScene
	assert(packed != null)

	var flight := packed.instantiate()
	root.add_child(flight)
	current_scene = flight
	await process_frame

	var terrain_scroller := flight.get_node("World/TerrainContainer/TerrainScroller")
	var terrain: TileMapLayer = terrain_scroller.get_node("Terrain")
	var player: PlayerCraft = flight.get_node("Actors/PlayerCraft")
	var spawner: EnemySpawner = flight.get_node("World/EncounterContainer/EnemySpawner")
	var bindings := flight.get_node("FlightStateBindings")
	var bullets: Node2D = flight.get_node("Bullets")

	assert(terrain_scroller.tile_layer == terrain)
	assert(not terrain.get_used_cells().is_empty())
	assert(spawner.player == player)
	assert(bindings.enemy_spawner == spawner)
	assert(bindings.player == player)
	assert(flight.has_node("FlightSettings"))
	assert(flight.has_node("UI/ScoreLabel"))
	assert(flight.has_node("UI/FlightProgressBar"))
	assert(flight.has_node("UI/HealthBarContainer"))

	player._broadcast_weapon_trigger(true)
	await process_frame
	player._broadcast_weapon_trigger(false)
	assert(bullets.get_child_count() > 0)

	await create_timer(1.2).timeout
	assert(flight.get_node("World/EncounterContainer").get_child_count() > 1)

	print("New Flight runtime parity: OK")
	quit()
