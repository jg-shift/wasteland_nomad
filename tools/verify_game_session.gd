extends Node


func _ready() -> void:
	assert(GameSession.is_initialized())
	assert(GameState.get_craft_hp() == GameSession.craft.health.get_hp())
	assert(GameState.get_player_hp() == GameSession.player.health.get_hp())

	GameState.take_craft_damage(10)
	assert(GameSession.craft.health.get_hp() == 90)

	GameState.add_craft_weapon_damage_upgrade(1)
	assert(GameSession.craft.upgrades.get_weapon_damage_upgrade() == 1)

	GameSession.initialize_new_game()
	assert(GameState.get_craft_hp() == 100)
	assert(GameState.get_craft_weapon_damage_upgrade() == 0)

	GameSession.set_current_location(&"first_hub")
	assert(GameSession.current_location_id == &"first_hub")

	assert(WorldLocations.has_location(&"first_hub"))
	assert(WorldLocations.has_location(&"tutorial_crash_site"))
	var registered_hub := WorldLocations.require_location(&"first_hub")
	assert(registered_hub.map_coordinates == Vector2.ZERO)
	assert(registered_hub.content_scene != null)
	var discovered_locations: Array[StringName] = [
		&"first_hub",
		&"tutorial_crash_site",
	]
	var available_destinations := WorldLocations.get_available_destinations(
		discovered_locations,
		&"tutorial_crash_site"
	)
	assert(available_destinations.size() == 1)
	assert(available_destinations[0].location_id == &"first_hub")

	var origin := LocationDefinition.new(
		&"first_hub",
		"First Hub",
		Vector2.ZERO,
		LocationDefinition.LocationType.HUB
	)
	var destination := LocationDefinition.new(
		&"second_hub",
		"Second Hub",
		Vector2(3.0, 4.0),
		LocationDefinition.LocationType.HUB
	)
	var journey := JourneyState.new(
		origin,
		destination,
		GameSession.craft.fuel_tank.get_gallons_per_map_unit(),
		12345
	)
	assert(is_equal_approx(journey.total_distance, 5.0))
	assert(is_equal_approx(journey.required_fuel_gallons, 2.5))
	assert(GameSession.begin_journey(journey))
	assert(journey.status == JourneyState.Status.IN_FLIGHT)
	assert(is_equal_approx(journey.advance(2.0, GameSession.craft.fuel_tank), 2.0))
	assert(is_equal_approx(GameSession.craft.fuel_tank.get_fuel_gallons(), 19.0))
	assert(journey.crash())
	assert(is_equal_approx(journey.advance(1.0, GameSession.craft.fuel_tank), 0.0))
	assert(journey.resume())
	assert(is_equal_approx(journey.advance(10.0, GameSession.craft.fuel_tank), 3.0))
	assert(journey.status == JourneyState.Status.COMPLETED)
	assert(is_equal_approx(GameSession.craft.fuel_tank.get_fuel_gallons(), 17.5))
	GameSession.clear_journey()
	assert(not GameSession.has_active_journey())

	var expedition := ExpeditionState.new(&"session_test_expedition")
	assert(GameSession.begin_expedition(expedition))
	assert(GameSession.require_active_expedition() == expedition)
	assert(GameState.score == expedition.score)
	GameState.add_points(25)
	assert(expedition.score.get_points() == 25)
	GameSession.clear_expedition()
	assert(not GameSession.has_active_expedition())
	assert(GameState.score != expedition.score)
	GameState.add_points(5)
	assert(GameState.get_points() == 5)
	assert(expedition.score.get_points() == 25)

	assert(PrologueSessionBootstrapper.start_new_game())
	assert(GameSession.current_location_id == &"prologue_origin")
	assert(GameSession.has_active_expedition())
	assert(GameSession.active_expedition.expedition_id == &"prologue")
	assert(GameSession.has_active_journey())
	assert(GameSession.active_journey.origin_location_id == &"prologue_origin")
	assert(GameSession.active_journey.destination_location_id == &"first_hub")
	assert(GameSession.active_journey.status == JourneyState.Status.IN_FLIGHT)
	assert(is_equal_approx(GameSession.active_journey.total_distance, 20.0))
	assert(is_equal_approx(GameSession.active_journey.required_fuel_gallons, 10.0))
	assert(GameState.score == GameSession.active_expedition.score)
	assert(GameState.get_points() == 0)

	var journey_adapter := FlightJourneyAdapter.new()
	add_child(journey_adapter)
	assert(journey_adapter.is_bound())
	assert(is_equal_approx(journey_adapter.get_segment_start_distance(), 0.0))
	assert(is_equal_approx(journey_adapter.get_segment_distance(), 20.0))
	GameState.set_flight_progress(0.25)
	assert(is_equal_approx(GameSession.active_journey.travelled_distance, 5.0))
	assert(is_equal_approx(GameSession.active_journey.consumed_fuel_gallons, 2.5))
	assert(is_equal_approx(GameSession.craft.fuel_tank.get_fuel_gallons(), 17.5))
	remove_child(journey_adapter)
	journey_adapter.free()

	assert(GameSession.active_journey.crash())
	assert(
		is_equal_approx(
			FlightDurationCalculator.calculate_duration(
				GameSession.active_journey.get_remaining_distance()
			),
			90.0
		)
	)
	GameState.take_craft_damage(10)
	var crashed_craft := CrashedCraft.new()
	add_child(crashed_craft)
	var crash_site_controller := CrashSiteController.new()
	crash_site_controller.crashed_craft = crashed_craft
	add_child(crash_site_controller)
	assert(crashed_craft.repair_state == CrashedCraft.RepairState.REPAIRABLE)
	crashed_craft.begin_repair()
	crashed_craft.complete_repair()
	assert(GameState.get_craft_hp() == GameState.get_craft_max_hp())
	remove_child(crash_site_controller)
	crash_site_controller.free()
	remove_child(crashed_craft)
	crashed_craft.free()

	assert(GameSession.active_journey.resume())
	var remaining_distance := GameSession.active_journey.get_remaining_distance()
	assert(
		is_equal_approx(
			GameSession.active_journey.advance(
				remaining_distance,
				GameSession.craft.fuel_tank
			),
			remaining_distance
		)
	)
	assert(GameSession.active_journey.status == JourneyState.Status.COMPLETED)
	var arrived_location := JourneyArrivalService.complete_active_journey()
	assert(arrived_location != null)
	assert(arrived_location.location_id == &"first_hub")
	assert(GameSession.current_location_id == &"first_hub")
	assert(GameSession.profile.is_location_discovered(&"first_hub"))
	assert(GameSession.profile.is_prologue_completed())
	assert(not GameSession.has_active_journey())
	assert(GameSession.has_active_expedition())
	assert(is_equal_approx(GameSession.craft.fuel_tank.get_fuel_gallons(), 10.0))

	var result := FileAccess.open("res://.godot/game_session_test.ok", FileAccess.WRITE)
	assert(result != null)
	result.store_string("GameSession runtime contracts: OK")
	get_tree().quit()
