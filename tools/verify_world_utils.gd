extends SceneTree


func _init() -> void:
	var utils := preload("res://autoload/WorldUtils.gd").new()

	utils.set_flight_speed_multiplier(1.0)
	assert(is_equal_approx(utils.flight_speed, 0.5))
	assert(is_equal_approx(utils.scroll_speed(), 220.0))

	utils.set_flight_speed_multiplier(3.0)
	assert(is_equal_approx(utils.flight_speed, 1.0))
	assert(is_equal_approx(utils.scroll_speed(), 660.0))

	utils.set_flight_speed_multiplier(10.0)
	assert(is_equal_approx(utils.flight_speed, 1.0))
	assert(is_equal_approx(utils.scroll_speed(), 2200.0))

	utils.set_base_scroll_speed_for_tiles(167.0, 1.5)
	utils.set_flight_speed_multiplier(1.0)
	assert(is_equal_approx(utils.scroll_speed(), 250.5))
	assert(is_equal_approx(utils.get_scroll_tiles_per_second(167.0), 1.5))

	utils.set_flight_speed_multiplier(10.0)
	assert(is_equal_approx(utils.scroll_speed(), 2505.0))

	print("WorldUtils tile-relative uncapped speed: OK")
	quit()
