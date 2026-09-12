extends Node
## Global utilities available to every script via WorldUtils.method_name()

## Normalized gameplay intensity used for steering and enemy tuning.
## World scrolling itself is not capped.
const BASE_FLIGHT_SPEED: float = 0.5
const FULL_INTENSITY_MULTIPLIER: float = 3.0

var flight_speed: float = BASE_FLIGHT_SPEED
var flight_speed_multiplier: float = 1.0

## Default world-scroll speed in px/sec. Multipliers scale it without an upper cap.
const DEFAULT_BASE_SCROLL_SPEED: float = 220.0

var _base_scroll_speed: float = DEFAULT_BASE_SCROLL_SPEED

## Temporary boost from active skills (e.g. afterburner). Independent of
## flight_speed_multiplier, which FlightSettings rewrites every frame.
var _flight_boost_multiplier: float = 1.0

## Returns current background scroll speed in px/sec.
func scroll_speed() -> float:
	return _base_scroll_speed * flight_speed_multiplier * _flight_boost_multiplier


## Configures the initial speed in tile-relative units.
## Example: tile_size=167 and tiles_per_second=1.5 produces 250.5 px/sec.
func set_base_scroll_speed_for_tiles(tile_size_px: float, tiles_per_second: float) -> void:
	if tile_size_px <= 0.0:
		push_error("WorldUtils: tile size must be greater than zero")
		return
	_base_scroll_speed = tile_size_px * maxf(0.0, tiles_per_second)


func reset_base_scroll_speed() -> void:
	_base_scroll_speed = DEFAULT_BASE_SCROLL_SPEED


func get_base_scroll_speed() -> float:
	return _base_scroll_speed


func get_scroll_tiles_per_second(tile_size_px: float) -> float:
	if tile_size_px <= 0.0:
		return 0.0
	return scroll_speed() / tile_size_px


func set_flight_speed_multiplier(value: float) -> void:
	flight_speed_multiplier = maxf(0.0, value)
	if flight_speed_multiplier <= 1.0:
		flight_speed = BASE_FLIGHT_SPEED * flight_speed_multiplier
		return

	var intensity_t := inverse_lerp(
		1.0,
		FULL_INTENSITY_MULTIPLIER,
		flight_speed_multiplier
	)
	flight_speed = lerpf(BASE_FLIGHT_SPEED, 1.0, clampf(intensity_t, 0.0, 1.0))

func set_flight_boost_multiplier(value: float) -> void:
	_flight_boost_multiplier = maxf(0.0, value)


func get_flight_boost_multiplier() -> float:
	return _flight_boost_multiplier


## Returns the visible world rect in global canvas coordinates.
## Works correctly whether or not a Camera2D is active.
func world_view_rect(viewport: Viewport) -> Rect2:
	var vp_rect := viewport.get_visible_rect()
	var canvas_xform := viewport.get_canvas_transform()
	var tl := canvas_xform.affine_inverse() * vp_rect.position
	var br := canvas_xform.affine_inverse() * (vp_rect.position + vp_rect.size)
	return Rect2(tl, br - tl)
